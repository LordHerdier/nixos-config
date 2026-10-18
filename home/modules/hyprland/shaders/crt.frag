#version 300 es

// CRT screen filter for Hyprland's decoration:screen_shader.
//
// The #version line must come first and must match Hyprland's vertex
// shader or the program fails to link. Hyprland picks tex320.vert only
// when a screen shader literally starts with "#version 320 es", and
// tex300.vert otherwise, so 300 es is the one to match here.
//
// Runs once per pixel per output per frame, on the final composite.
// Of the uniforms Hyprland offers, only `fullSize` is used: `time` and
// `pointer_position` force debug:damage_tracking off, which means a
// full redraw every frame on both monitors.
//
// Caveat worth remembering while tuning: Hyprland warps pixels, not
// pointer coordinates. The cursor is drawn into `tex` (software cursors
// are on, see 30-input.nix) so it follows the curve visually, but clicks
// still land where the undistorted pointer is. Keep CURVE small or the
// mismatch near the edges becomes maddening.
//
// Stages, in order: barrel distortion, convergence error, beam profile,
// phosphor mask, vignette, bezel. Everything between linearize() and
// encode() happens in linear light, because multiplying sRGB-encoded
// values darkens midtones faster than a real tube does. The beam and
// mask ideas are adapted from the libretro crt-lottes, crt-easymode and
// crt-geom shaders, reworked to run in output-pixel space: those
// shaders spend most of their effort reconstructing a 240p source grid,
// which does not exist here — the composite arrives at native
// resolution, so only their output-space maths is useful.

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform vec2 fullSize; // this output's size in physical pixels

layout(location = 0) out vec4 fragColor;

// -- glass geometry ---------------------------------------------------
const float CURVE        = 0.14; // barrel distortion; 0.0 is flat glass
const float CORNER_SIZE  = 0.01; // bezel corner radius, in widths
const float CORNER_AA_PX = 1.5;  // softness of the bezel edge, in pixels

// -- beam -------------------------------------------------------------
const float SCAN_PERIOD   = 6.0;  // physical pixels per scanline pair
const float SCAN_DEPTH    = 0.75; // 0.0 disables scanlines entirely
const float SCAN_HARD     = -1.0; // beam falloff; more negative is tighter
const float BEAM_MIN      = 0.30; // beam width in the shadows, in periods
const float BEAM_MAX      = 0.55; // beam width in the highlights
const float BEAM_SHAPE    = 2.5;  // how fast width tracks brightness
const float SCAN_KEEP_MIN = 0.30; // floor on highlight protection
const float SCAN_KEEP_MAX = 0.65; // ceiling on highlight protection

// -- phosphor mask ----------------------------------------------------
const float MASK_DARK  = 0.80; // the two channels the stripe is not
const float MASK_LIGHT = 1.00; // the channel the stripe is

// -- tube -------------------------------------------------------------
const float ABERR_PX     = 1.2;  // r/b convergence error, in pixels
const float VIGNETTE     = 0.06; // corner falloff; 0.0 is none
const float BRIGHT_BOOST = 1.15; // pays back what beam and mask take
const float GAMMA_IN     = 2.2;  // decode; 2.2 is plain sRGB
const float GAMMA_OUT    = 2.2;  // encode; drop it to lift the midtones

// -- halation ---------------------------------------------------------
// Off by default: these are the only stage that costs extra taps (12 of
// them, on top of the 3 the convergence error needs), which is real
// money at 2880x1920 every frame. Both being const means the compiler
// folds the whole block away while they are 0.0, so it is free until
// you want it. Raise HALATION first; it is the light scattering inside
// the glass, and it is what makes white text on a dark terminal glow.
const float HALATION    = 0.0; // bright-on-dark bleed, squared falloff
const float DIFFUSION   = 0.0; // flat haze across the whole picture
const float HALATION_PX = 2.0; // scatter radius, in pixels

const float PI = 3.14159265;

vec3 linearize(vec3 c) { return pow(c, vec3(GAMMA_IN)); }
vec3 encode(vec3 c)    { return pow(max(c, 0.0), vec3(1.0 / GAMMA_OUT)); }

// Aperture grille: vertical r/g/b stripes on a three-pixel pitch.
//
// This is deliberately fed gl_FragCoord rather than the distorted uv.
// The phosphor stripes are painted on the physical face of the tube, so
// they stay on the pixel grid while the image bends behind them; running
// the mask through the curve instead makes the stripes visibly fan out
// at the edges. For a slot mask, shear before taking the fraction:
// px.x += px.y * 3.0, then fract(px.x * 0.1666666) below.
vec3 maskWeight(vec2 px) {
    vec3 m = vec3(MASK_DARK);
    float x = fract(px.x * (1.0 / 3.0));

    if      (x < 0.333) m.r = MASK_LIGHT;
    else if (x < 0.666) m.g = MASK_LIGHT;
    else                m.b = MASK_LIGHT;

    return m;
}

// Rounded bezel with an antialiased edge, from crt-geom. Returns 0
// outside the glass and ramps to 1 just inside it, which is the part
// a hard inside/outside test cannot do: the curve crosses the pixel
// grid at a shallow angle along the top and bottom, so a binary cut
// leaves a visibly stepped edge there. Scaling by y/x keeps the corner
// radius circular rather than stretched to the aspect ratio.
float corner(vec2 uv) {
    vec2 c = min(uv, 1.0 - uv) * vec2(1.0, fullSize.y / fullSize.x);
    vec2 r = vec2(CORNER_SIZE);
    c = r - min(c, r);

    return clamp((r.x - length(c)) * (fullSize.x / CORNER_AA_PX), 0.0, 1.0);
}

// Twelve-tap approximation of a gaussian, cross weighted double against
// the diagonals. Only ever called when halation is switched on.
vec3 scatter(vec2 uv, vec2 r) {
    vec3 s = vec3(0.0);

    s += 2.0 * linearize(texture(tex, uv + vec2( r.x,  0.0)).rgb);
    s += 2.0 * linearize(texture(tex, uv + vec2(-r.x,  0.0)).rgb);
    s += 2.0 * linearize(texture(tex, uv + vec2( 0.0,  r.y)).rgb);
    s += 2.0 * linearize(texture(tex, uv + vec2( 0.0, -r.y)).rgb);
    s += linearize(texture(tex, uv + vec2( r.x,  r.y)).rgb);
    s += linearize(texture(tex, uv + vec2( r.x, -r.y)).rgb);
    s += linearize(texture(tex, uv + vec2(-r.x,  r.y)).rgb);
    s += linearize(texture(tex, uv + vec2(-r.x, -r.y)).rgb);

    return s / 12.0;
}

void main() {
    // Distort around screen centre: push each point outward by an amount
    // that grows with the square of its distance from the opposite axis,
    // which is the cheap approximation of a spherical tube face.
    vec2 uv = v_texcoord * 2.0 - 1.0;
    vec2 off = abs(uv.yx) * CURVE;
    uv += uv * off * off;
    uv = uv * 0.5 + 0.5;

    // The curve pulls the image in from the edges; everything outside is
    // bezel. Without this the sampler clamps and smears the edge pixels.
    // corner() softens the boundary, but bailing here keeps the whole
    // bezel region off the expensive path.
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Convergence error: the three guns never landed on quite the same
    // spot, so red and blue sit a hair either side of green. Scaled by
    // fullSize so it stays 1.2 real pixels on both the 1440p and the
    // 2880x1920 panel rather than drifting with resolution.
    float aberr = ABERR_PX / fullSize.x;
    vec3 c;
    c.r = texture(tex, uv + vec2( aberr, 0.0)).r;
    c.g = texture(tex, uv).g;
    c.b = texture(tex, uv + vec2(-aberr, 0.0)).b;
    c = linearize(c);

    vec3 glow = vec3(0.0);
    if (HALATION > 0.0 || DIFFUSION > 0.0) {
        // Keep only the part of the neighbourhood that is brighter than
        // this pixel: light scatters out of the bright areas into the
        // dark ones, not the other way around.
        glow = max(scatter(uv, vec2(HALATION_PX) / fullSize) - c, 0.0);
    }

    // Beam profile. A real beam is not a fixed-depth ripple: it widens
    // as it is driven harder, so highlights bloom into their neighbours
    // and shadows keep thin, well separated lines. `bright` mixes peak
    // channel with luma so a saturated red lights up as readily as a
    // grey of the same luminance.
    //
    // Measured along the distorted uv, unlike the mask: the raster is
    // traced on the inside of the tube, so the scanlines bend with the
    // image.
    float bright = (max(max(c.r, c.g), c.b)
                    + dot(c, vec3(0.2126, 0.7152, 0.0722))) * 0.5;
    float beam = mix(BEAM_MIN, BEAM_MAX, pow(bright, 1.0 / BEAM_SHAPE));
    float d = fract(uv.y * fullSize.y / SCAN_PERIOD) - 0.5;
    float scan = mix(1.0, exp2(SCAN_HARD * pow(abs(d) / beam, 2.0)), SCAN_DEPTH);

    // Give the highlights most of their unscanned value back. Without
    // this the scanlines read as a grey mesh laid over the picture
    // instead of as the structure of the picture itself, because white
    // text ends up darker than the paper it is meant to be glowing on.
    vec3 lit = c * scan;
    c = mix(lit, c, clamp(bright, SCAN_KEEP_MIN, SCAN_KEEP_MAX));

    c += glow * glow * HALATION;
    c *= maskWeight(gl_FragCoord.xy);
    c += glow * DIFFUSION;

    // The beam and the mask both only ever take light away; one stripe
    // lit out of three averages to (1 + 2*MASK_DARK)/3 per channel, so
    // without this the desktop just looks dimmer rather than different.
    c *= BRIGHT_BOOST;

    // uv*(1-uv) peaks at 0.25 per axis, so the product peaks at 0.0625;
    // scaling by 15 keeps the screen centre just shy of clipping.
    vec2 v = uv * (1.0 - uv);
    c *= pow(clamp(v.x * v.y * 15.0, 0.0, 1.0), VIGNETTE);

    c *= corner(uv);

    fragColor = vec4(encode(c), 1.0);
}

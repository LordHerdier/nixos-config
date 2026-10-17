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

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform vec2 fullSize; // this output's size in physical pixels

layout(location = 0) out vec4 fragColor;

const float CURVE       = 0.14; // barrel distortion; 0.0 is flat glass
const float SCAN_PERIOD = 3.0;  // physical pixels per scanline pair
const float SCAN_DEPTH  = 0.08; // how dark the dark lines get
const float VIGNETTE    = 0.06; // corner falloff; 0.0 is none
const float ABERR_PX    = 1.2;  // r/b convergence error, in pixels

const float PI = 3.14159265;

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

    c *= 1.0 - SCAN_DEPTH * (0.5 + 0.5 * sin(uv.y * (fullSize.y / SCAN_PERIOD) * PI));

    // uv*(1-uv) peaks at 0.25 per axis, so the product peaks at 0.0625;
    // scaling by 15 keeps the screen centre just shy of clipping.
    vec2 v = uv * (1.0 - uv);
    c *= pow(clamp(v.x * v.y * 15.0, 0.0, 1.0), VIGNETTE);

    fragColor = vec4(c, 1.0);
}

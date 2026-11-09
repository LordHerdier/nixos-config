/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const int smartgaps                 = 0;  /* 1 means no outer gap when there is only one window */
static const int monoclegaps               = 0;  /* 1 means outer gaps in monocle layout */
static const unsigned int borderpx         = 1;  /* border pixel of windows */
/* Gaps (84-vanitygaps.patch), 16px everywhere. Despite the names, in tile()
 * ih is the gap between stacked windows, iv between the master and stack
 * columns, oh the top/bottom screen edge and ov the left/right one. */
static const unsigned int gappih           = 16; /* gap between stacked windows */
static const unsigned int gappiv           = 16; /* gap between master and stack columns */
static const unsigned int gappoh           = 16; /* gap at the top/bottom screen edge */
static const unsigned int gappov           = 16; /* gap at the left/right screen edge */
static const unsigned int snap             = 32; /* snap pixel */
static const unsigned int systrayspacing   = 2; /* systray spacing */
static const int showsystray               = 1; /* 0 means no systray */
static const int showbar                   = 1; /* 0 means no bar */
static const int topbar                    = 1; /* 0 means bottom bar */
static const char *fonts[]                 = {"monospace:size=12"};
/* Fallback colours (OneShot), used until loadcolors (75-theme-colours.patch)
 * reads the colours file at startup / on SIGUSR2, or when there is none.
 * pkgs/dwl/default.nix overrides them with -D flags. */
#ifndef COLORS_SYSTEM
#define COLORS_SYSTEM "/etc/dwl/colors"
#endif
#ifndef COL_BG
#define COL_BG          0x000000ff
#endif
#ifndef COL_FG
#define COL_FG          0xcbb8ffff
#endif
#ifndef COL_SURFACE
#define COL_SURFACE     0x000000ff
#endif
#ifndef COL_BORDER_INACTIVE
#define COL_BORDER_INACTIVE 0x4a3d66ff
#endif
#ifndef COL_MUTED
#define COL_MUTED       0x4a3d66ff
#endif
#ifndef COL_ACCENT
#define COL_ACCENT      0x9664ffff
#endif
#ifndef COL_ACCENT_FG
#define COL_ACCENT_FG   0x000000ff
#endif
#ifndef COL_BORDER
#define COL_BORDER      0x9664ffff
#endif
#ifndef COL_SUCCESS
#define COL_SUCCESS     0x9664ffff
#endif
#ifndef COL_URGENT
#define COL_URGENT      0x6442a5ff
#endif
static float rootcolor[]                   = COLOR(COL_BG);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f}; /* You can also use glsl colors */
static int enableautoswallow = 1; /* enables autoswallowing newly spawned clients */
static float swallowborder = 1.0f; /* add this multiplied by borderpx to border when a client is swallowed */
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { COL_FG,        COL_SURFACE, COL_BORDER_INACTIVE },
	[SchemeSel]  = { COL_ACCENT_FG, COL_ACCENT,  COL_BORDER },
	[SchemeUrg]  = { 0,             0,           COL_URGENT },
};
/* the " | " between the tray and the status text, matching slstatus's SEP */
static uint32_t sepcolors[3]               = { COL_MUTED, COL_SURFACE, COL_BORDER_INACTIVE };
/* ^fg(good) in the status line */
static uint32_t successcolor               = COL_SUCCESS;

static const float default_opacity = 0.9f;

/* Fragment shader run over each output while togglescreenshader is on
 * (72-screen-shader). SCREEN_SHADER comes from pkgs/dwl/default.nix; the
 * fallback is where Home Manager installs hyprCRT. */
#ifndef SCREEN_SHADER
#define SCREEN_SHADER "/etc/profiles/per-user/charlotte/share/hyprCRT/crt.frag"
#endif
static const char *screenshader = SCREEN_SHADER;

/* tagging */
static char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };

/* logging */
static int log_level = WLR_ERROR;

/* Autostart: each command is NULL-terminated, the list ends with a bare NULL */
static const char *const autostart[] = {
	"st-wl", "zsh", "-i", "-c", "t", NULL,
	NULL /* terminate */
};

static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   iscentered   isterm   noswallow   alpha              monitor */
	{ "st-wl",            NULL,       0,            0,           0,           1,       0,          default_opacity,   -1 },
	{ "floatterm",        NULL,       0,            1,           0,           0,       1,          default_opacity,   -1 }, /* Super+T terminal */
	{ "modal",            NULL,       0,            1,           1,           0,       1,          default_opacity,   -1 }, /* st-wl control popups (MODAL below) */
	{ "Gimp_EXAMPLE",     NULL,       0,            1,           0,           0,       0,          default_opacity,   -1 }, /* Start on currently visible tags floating, not tiled */
	{ "firefox_EXAMPLE",  NULL,       1 << 8,       0,           0,           0,       0,          default_opacity,   -1 }, /* Start on ONLY tag "9" */
    /* default/example rule: can be changed but cannot be eliminated; at least one rule must exist */
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* monitors */
/* (x=-1, y=-1) is reserved as an "autoconfigure" monitor position indicator
 * WARNING: negative values other than (-1, -1) cause problems with Xwayland clients due to
 * https://gitlab.freedesktop.org/xorg/xserver/-/issues/899 */
/* Mirrors home/modules/hyprland/monitors.lua: docked, DP-4 (Anker hub) at the
 * origin, laptop panel to its right. eDP-1 is pinned at x=2560 rather than
 * auto so booting docked can't stack it on DP-4. resx/resy/rate pick from the
 * output's modes (45-monitorconfig), 0 meaning preferred; DP-4 prefers
 * 59.95Hz, hence the explicit 165.08. */
static const MonitorRule monrules[] = {
	/* name     mfact  nmaster scale layout       rotate/reflect              x     y   resx  resy  rate     mode adaptive */
	{ "eDP-1",  0.55f, 1,      1.33f, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, 2560, 0,  2880, 1920, 120.0f,  0,   0 },
	{ "DP-4",   0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, 0,    0,  2560, 1440, 165.08f, 0,   0 },
	{ NULL,     0.55f, 1,      1.33f, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, -1,   -1, 0,    0,    0.0f,    0,   0 },
	/* default monitor rule: can be changed but cannot be eliminated; at least one monitor rule must exist */
};

/* Output each tag lives on (30-tagmon), as Hyprland's workspace rules: DP-4
 * the odd tags, eDP-1 the even. Plugging DP-4 in pulls its tags' windows
 * over; without it every tag uses the focused monitor. */
static const char *tagmons[] = {
	"DP-4", "eDP-1", "DP-4", "eDP-1", "DP-4",
	"eDP-1", "DP-4", "eDP-1", "DP-4", "eDP-1",
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.options = "ctrl:nocaps",
	*/
	/* Colemak first so it's the login layout, as in
	 * home/modules/hyprland/30-input.nix. Super+Alt+K switches. */
	.layout = "us,us",
	.variant = "colemak,",
	.options = NULL,
};

/* Run after the layout changes and dwl has written its name to
 * $XDG_RUNTIME_DIR/dwl-xkb-layout (51-xkb-layout), so the bar redraws */
static const char *const xkblayoutcmd[] = { "dwl-bar-refresh", NULL };

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 1;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;

/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, KEY,            tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,KEY,toggletag,  {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* dmenu-like program the systray uses to show item menus */
static const char *dmenucmd[] = { "wofi", "--dmenu", NULL };

/* commands */
/* No-op placeholder for a Hyprland bind that runs `noctalia msg <verb>` and
 * has no dwl equivalent yet; grep NOCTALIA_STUB for the remaining ones. */
#define NOCTALIA_STUB(verb) SHCMD("true # TODO(noctalia): " verb)

/* Raise/lower the default sink (capped at 100%), then redraw the bar. */
#define VOLCMD(delta) "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " delta "; dwl-bar-refresh"

static const char *termcmd[]  = { "st-wl", NULL };
/* -c sets the app_id, matched by a floating rule above; -g is columnsxrows
 * (a flag added by pkgs/st-wl/patches/10-geometry-flag.patch). */
static const char *floatterm[] = { "st-wl", "-c", "floatterm", "-g", "80x20", NULL };
/* Toggles a control popup: a centred floating st-wl (the "modal" rule).
 * Size and command per name are in modules/features/dwl/scripts/dwl-modal.sh,
 * shared with the bar's click regions. */
#define MODAL(name) { .v = (const char*[]){ "dwl-modal", name, NULL } }

#define SHIFT WLR_MODIFIER_SHIFT
#define CTRL  WLR_MODIFIER_CTRL
#define ALT   WLR_MODIFIER_ALT

/* The only binds that still fire while the session is locked
 * (39-locked-keys.patch). */
static const xkb_keysym_t lockedkeys[] = {
	XKB_KEY_XF86AudioRaiseVolume,
	XKB_KEY_XF86AudioLowerVolume,
	XKB_KEY_XF86AudioMute,
	XKB_KEY_XF86AudioMicMute,
	XKB_KEY_XF86AudioPlay,
	XKB_KEY_XF86AudioStop,
	XKB_KEY_XF86AudioPrev,
	XKB_KEY_XF86AudioNext,
	XKB_KEY_XF86MonBrightnessUp,
	XKB_KEY_XF86MonBrightnessDown,
	/* Super+= / Super+- and their Shift forms. Matched by keysym only, but the
	 * bind still needs its modifiers, so bare = and - reach the locker. */
	XKB_KEY_equal,
	XKB_KEY_minus,
	XKB_KEY_plus,
	XKB_KEY_underscore,
};

/* Ported from home/modules/hyprland/binds.lua, minus pseudotiling and
 * pinning (dwl has neither). dwl-only master/layout binds live on Ctrl,
 * which Hyprland leaves free. */
static const Key keys[] = {
	/* modifier                  key                  function          argument */
	/* Essentials */
	{ MODKEY,                    XKB_KEY_q,           killclient,       {0} },
	{ MODKEY,                    XKB_KEY_l,           spawn,            SHCMD("qylock-lock") },
	{ MODKEY|SHIFT,              XKB_KEY_l,           quit,             {0} },

	/* Wallpapers */
	{ MODKEY|ALT,                XKB_KEY_1,           spawn,            SHCMD("dwl-wallpaper next") },
	{ MODKEY|ALT,                XKB_KEY_2,           spawn,            SHCMD("dwl-wallpaper prev") },
	{ MODKEY|ALT,                XKB_KEY_3,           spawn,            SHCMD("dwl-wallpaper rand") },
	{ MODKEY|ALT,                XKB_KEY_4,           spawn,            MODAL("wallpaper") },

	/* Launchers */
	{ MODKEY,                    XKB_KEY_space,       spawn,            SHCMD("wofi --show drun") },
	{ MODKEY,                    XKB_KEY_slash,       spawn,            MODAL("settings") },
	{ MODKEY,                    XKB_KEY_h,           spawn,            MODAL("binds") },
	{ MODKEY,                    XKB_KEY_Return,      spawn,            {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_t,           spawn,            {.v = floatterm} },
	{ MODKEY|SHIFT,              XKB_KEY_t,           spawn,            SHCMD("hacky-tts-toggle") },
	{ MODKEY,                    XKB_KEY_grave,       spawn,            SHCMD("hacky-launcher-toggle") },
	{ MODKEY|SHIFT,              XKB_KEY_s,           spawn,            SHCMD("dwl-screenshot") },
	{ MODKEY|SHIFT,              XKB_KEY_c,           spawn,            SHCMD("hyprpicker -qaf rgb") },
	{ MODKEY|SHIFT,              XKB_KEY_w,           spawn,            SHCMD("moonlight stream 'nico' 'desktop'") },
	{ MODKEY|SHIFT,              XKB_KEY_e,           spawn,            SHCMD("nautilus") },
	{ MODKEY|SHIFT,              XKB_KEY_A,           spawn,            SHCMD("easyeffects") },
	{ MODKEY,                    XKB_KEY_c,           spawn,            SHCMD("st-wl zsh -i -c nvim") },
	{ MODKEY,                    XKB_KEY_b,           spawn,            SHCMD("zen-beta") },
	{ MODKEY,                    XKB_KEY_m,           spawn,            SHCMD("st-wl zsh -i -c spotify_player") },
	{ MODKEY,                    XKB_KEY_d,           spawn,            SHCMD("st-wl zsh -i -c concord") },

	/* Noctalia launchers */
	{ MODKEY,                    XKB_KEY_v,           spawn,            MODAL("clipboard") },
	{ MODKEY,                    XKB_KEY_period,      spawn,            MODAL("emoji") },
	{ MODKEY|ALT,                XKB_KEY_Tab,         spawn,            MODAL("windows") },
	{ MODKEY|SHIFT,              XKB_KEY_space,       spawn,            NOCTALIA_STUB("panel-toggle launcher \"/pan \"") },

	/* Noctalia panels & menus */
	{ MODKEY,                    XKB_KEY_a,           spawn,            MODAL("mixer") },
	{ MODKEY|ALT,                XKB_KEY_a,           spawn,            MODAL("network") },
	{ MODKEY,                    XKB_KEY_o,           spawn,            MODAL("session") },
	{ MODKEY,                    XKB_KEY_w,           spawn,            MODAL("notifications") },
	{ MODKEY|ALT,                XKB_KEY_w,           spawn,            SHCMD("dwl-dnd") },
	{ MODKEY,                    XKB_KEY_comma,       spawn,            NOCTALIA_STUB("settings-toggle") },
	{ MODKEY,                    XKB_KEY_k,           spawn,            MODAL("calendar") },

	/* Toggles. Shift+B is dwl's own bar, not Noctalia's. */
	{ MODKEY|SHIFT,              XKB_KEY_b,           togglebar,        {0} },
	{ MODKEY|SHIFT,              XKB_KEY_d,           spawn,            NOCTALIA_STUB("theme-mode-toggle") },
	{ MODKEY|SHIFT,              XKB_KEY_n,           spawn,            SHCMD("dwl-nightlight") },
	{ MODKEY|SHIFT,              XKB_KEY_i,           spawn,            SHCMD("dwl-caffeine") },
	{ MODKEY|SHIFT,              XKB_KEY_p,           spawn,            SHCMD("dwl-powersave") },
	/* Colemak <-> QWERTY (51-xkb-layout) */
	{ MODKEY|ALT,                XKB_KEY_k,           switchxkblayout,  {.i = +1} },

	/* Noctalia plugins */
	{ MODKEY|ALT,                XKB_KEY_s,           spawn,            SHCMD("dwl-airpods") },
	{ MODKEY|SHIFT,              XKB_KEY_r,           spawnfocused,     SHCMD("dwl-record") },

	/* Display filters */
	{ MODKEY|SHIFT,              XKB_KEY_g,           togglescreenshader, {0} },

	/* Window management */
	{ MODKEY,                    XKB_KEY_f,           togglefullscreen, {0} },
	{ MODKEY|SHIFT,              XKB_KEY_f,           togglefloating,   {0} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_A,           toggleswallow,    {0} },
	{ MODKEY|CTRL,               XKB_KEY_a,           toggleautoswallow,{0} },

	/* Focus: Colemak n/i/u/e and the arrows, as in Hyprland. Directional
	 * (48-focusdir), crossing outputs at the edge and wrapping; monocle
	 * steps the stack instead */
	{ MODKEY,                    XKB_KEY_n,           focusdir,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_i,           focusdir,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY,                    XKB_KEY_u,           focusdir,         {.i = WLR_DIRECTION_UP} },
	{ MODKEY,                    XKB_KEY_e,           focusdir,         {.i = WLR_DIRECTION_DOWN} },
	{ MODKEY,                    XKB_KEY_Left,        focusdir,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_Right,       focusdir,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY,                    XKB_KEY_Up,          focusdir,         {.i = WLR_DIRECTION_UP} },
	{ MODKEY,                    XKB_KEY_Down,        focusdir,         {.i = WLR_DIRECTION_DOWN} },

	/* dwl-only: master area, layouts, monitors */
	{ MODKEY|CTRL,               XKB_KEY_n,           setmfact,         {.f = -0.05f} },
	{ MODKEY|CTRL,               XKB_KEY_i,           setmfact,         {.f = +0.05f} },
	{ MODKEY|CTRL,               XKB_KEY_o,           setopacity,       {.f = +0.05f} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_O,           setopacity,       {.f = -0.05f} },
	{ MODKEY|CTRL,               XKB_KEY_u,           incnmaster,       {.i = +1} },
	{ MODKEY|CTRL,               XKB_KEY_e,           incnmaster,       {.i = -1} },
	/* Gaps, 2px a step on this monitor: ] grows, [ shrinks. Super+Ctrl for
	 * all of them / outer (Shift) / inner (Alt), Super+Alt for the inner gaps
	 * alone, Super for the screen edges alone; there Shift picks the other
	 * axis. Super+Ctrl+\ turns gaps off and on, Super+Ctrl+Shift+\ resets
	 * them to the sizes above. Brackets rather than = / -, which are in
	 * lockedkeys and would fire under the locker */
	{ MODKEY|CTRL,               XKB_KEY_bracketright, incgaps,         {.i = +2} },
	{ MODKEY|CTRL,               XKB_KEY_bracketleft, incgaps,          {.i = -2} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_braceright,  incogaps,         {.i = +2} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_braceleft,   incogaps,         {.i = -2} },
	{ MODKEY|CTRL|ALT,           XKB_KEY_bracketright, incigaps,        {.i = +2} },
	{ MODKEY|CTRL|ALT,           XKB_KEY_bracketleft, incigaps,         {.i = -2} },
	{ MODKEY|ALT,                XKB_KEY_bracketright, incihgaps,       {.i = +2} },
	{ MODKEY|ALT,                XKB_KEY_bracketleft, incihgaps,        {.i = -2} },
	{ MODKEY|ALT|SHIFT,          XKB_KEY_braceright,  incivgaps,        {.i = +2} },
	{ MODKEY|ALT|SHIFT,          XKB_KEY_braceleft,   incivgaps,        {.i = -2} },
	{ MODKEY,                    XKB_KEY_bracketright, incohgaps,       {.i = +2} },
	{ MODKEY,                    XKB_KEY_bracketleft, incohgaps,        {.i = -2} },
	{ MODKEY|SHIFT,              XKB_KEY_braceright,  incovgaps,        {.i = +2} },
	{ MODKEY|SHIFT,              XKB_KEY_braceleft,   incovgaps,        {.i = -2} },
	{ MODKEY|CTRL,               XKB_KEY_backslash,   togglegaps,       {0} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_bar,         defaultgaps,      {0} },
	{ MODKEY|CTRL,               XKB_KEY_Return,      zoom,             {0} },
	/* Alt+Tab-style: hold Super, Tab steps through windows in recently used
	 * order, releasing Super keeps the one shown, Escape goes back */
	{ MODKEY,                    XKB_KEY_Tab,         mrucycle,         {.i = +1} },
	{ MODKEY|SHIFT,              XKB_KEY_Tab,         mrucycle,         {.i = -1} },
	{ MODKEY|CTRL,               XKB_KEY_Tab,         view,             {0} },
	{ MODKEY|CTRL,               XKB_KEY_t,           setlayout,        {.v = &layouts[0]} },
	{ MODKEY|CTRL,               XKB_KEY_f,           setlayout,        {.v = &layouts[1]} },
	{ MODKEY|CTRL,               XKB_KEY_m,           setlayout,        {.v = &layouts[2]} },
	{ MODKEY|CTRL,               XKB_KEY_space,       setlayout,        {0} },
	{ MODKEY|CTRL,               XKB_KEY_comma,       focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|CTRL,               XKB_KEY_period,      focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_comma,       tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_period,      tagmon,           {.i = WLR_DIRECTION_RIGHT} },

	/* Workspaces: 1-9, and 0 for the tenth */
	TAGKEYS(                     XKB_KEY_1,           0),
	TAGKEYS(                     XKB_KEY_2,           1),
	TAGKEYS(                     XKB_KEY_3,           2),
	TAGKEYS(                     XKB_KEY_4,           3),
	TAGKEYS(                     XKB_KEY_5,           4),
	TAGKEYS(                     XKB_KEY_6,           5),
	TAGKEYS(                     XKB_KEY_7,           6),
	TAGKEYS(                     XKB_KEY_8,           7),
	TAGKEYS(                     XKB_KEY_9,           8),
	TAGKEYS(                     XKB_KEY_0,           9),

	/* Hardware keys */
	{ 0, XKB_KEY_XF86AudioRaiseVolume,   spawn, SHCMD(VOLCMD("5%+")) },
	{ 0, XKB_KEY_XF86AudioLowerVolume,   spawn, SHCMD(VOLCMD("5%-")) },
	{ 0, XKB_KEY_XF86AudioMute,          spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; dwl-bar-refresh") },
	{ 0, XKB_KEY_XF86AudioMicMute,       spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") },
	{ 0, XKB_KEY_XF86AudioPlay,          spawn, SHCMD("playerctl play-pause") },
	{ 0, XKB_KEY_XF86AudioStop,          spawn, SHCMD("playerctl stop") },
	{ 0, XKB_KEY_XF86AudioPrev,          spawn, SHCMD("playerctl previous") },
	{ 0, XKB_KEY_XF86AudioNext,          spawn, SHCMD("playerctl next") },
	{ 0, XKB_KEY_XF86MonBrightnessUp,    spawn, SHCMD("brightnessctl set 5%+; dwl-bar-refresh") },
	{ 0, XKB_KEY_XF86MonBrightnessDown,  spawn, SHCMD("brightnessctl set 5%-; dwl-bar-refresh") },

	/* Super+= / Super+- volume, Super+Shift+= / Super+Shift+- brightness. With
	 * Shift held the keysyms are the shifted ones, plus and underscore. */
	{ MODKEY,                    XKB_KEY_equal,       spawn,            SHCMD(VOLCMD("5%+")) },
	{ MODKEY,                    XKB_KEY_minus,       spawn,            SHCMD(VOLCMD("5%-")) },
	{ MODKEY|SHIFT,              XKB_KEY_plus,        spawn,            SHCMD("brightnessctl set 5%+; dwl-bar-refresh") },
	{ MODKEY|SHIFT,              XKB_KEY_underscore,  spawn,            SHCMD("brightnessctl set 5%-; dwl-bar-refresh") },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_BackSpace, quit, {0} },
	/* Ctrl-Alt-Fx is used to switch to another VT, if you don't know what a VT is
	 * do not remove them.
	 */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_F##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ ClkLtSymbol, 0,      BTN_LEFT,   setlayout,      {.v = &layouts[0]} },
	{ ClkLtSymbol, 0,      BTN_RIGHT,  setlayout,      {.v = &layouts[2]} },
	{ ClkTitle,    0,      BTN_MIDDLE, zoom,           {0} },
	{ ClkClient,   MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ ClkClient,   MODKEY|WLR_MODIFIER_SHIFT, BTN_LEFT, moveresize, {.ui = CurResize} },
	{ ClkClient,   MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ ClkClient,   MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
	{ ClkLauncher, 0,      BTN_LEFT,   spawn,          SHCMD("wofi --show drun") },
	{ ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
	{ ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
	{ ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
	{ ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
	{ ClkTray,     0,      BTN_LEFT,   trayactivate,   {0} },
	{ ClkTray,     0,      BTN_RIGHT,  traymenu,       {0} },
};

static const Axis axes[] = {
	{ MODKEY, AxisUp,   spawn, SHCMD(VOLCMD("1%+")) },
	{ MODKEY, AxisDown, spawn, SHCMD(VOLCMD("1%-")) },
};

/* Scrolling over the status text outside a ^us()/^ds() region
 * (18-bar-status-volume.patch). Nothing bound: slstatus's own regions handle
 * volume. C forbids an empty array, so one NULL-func entry, which the lookup
 * skips. */
static const Axis statusaxes[] = {
	{ 0, AxisUp, NULL, {0} },
};

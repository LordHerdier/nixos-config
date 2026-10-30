/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 0;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const unsigned int borderpx         = 1;  /* border pixel of windows */
static const unsigned int snap             = 32; /* snap pixel */
static const int showbar                   = 1; /* 0 means no bar */
static const int topbar                    = 1; /* 0 means bottom bar */
static const char *fonts[]                 = {"monospace:size=12"};
static const float rootcolor[]             = COLOR(0x000000ff);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f}; /* You can also use glsl colors */
static int enableautoswallow = 1; /* enables autoswallowing newly spawned clients */
static float swallowborder = 1.0f; /* add this multiplied by borderpx to border when a client is swallowed */
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xcbb8ffff, 0x000000ff, 0x4a3d66ff },
	[SchemeSel]  = { 0x000000ff, 0x9664ffff, 0x9664ffff },
	[SchemeUrg]  = { 0,          0,          0x6442a5ff },
};

static const float default_opacity = 0.9;

/* tagging */
static char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };

/* logging */
static int log_level = WLR_ERROR;

/* Autostart: each command is NULL-terminated, the list ends with a bare NULL */
static const char *const autostart[] = {
	"kitty", "zsh", "-i", "-c", "t", NULL,
	NULL /* terminate */
};

static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   isterm   noswallow   alpha              monitor */
	{ "kitty",            NULL,       0,            0,           1,       0,          default_opacity,   -1 },
	{ "floatterm",        NULL,       0,            1,           0,       1,          default_opacity,   -1 }, /* Super+T terminal */
	{ "Gimp_EXAMPLE",     NULL,       0,            1,           0,       0,          default_opacity,   -1 }, /* Start on currently visible tags floating, not tiled */
	{ "firefox_EXAMPLE",  NULL,       1 << 8,       0,           0,       0,          default_opacity,   -1 }, /* Start on ONLY tag "9" */
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
static const MonitorRule monrules[] = {
   /* name        mfact  nmaster scale layout       rotate/reflect                x    y
    * example of a HiDPI laptop monitor:
    { "eDP-1",    0.5f,  1,      2,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 }, */
	{ NULL,       0.55f, 1,      1.33,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	/* default monitor rule: can be changed but cannot be eliminated; at least one monitor rule must exist */
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.options = "ctrl:nocaps",
	*/
	.layout = "us",
	.variant = "colemak",
	.options = NULL,
};

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

/* commands */
/* Placeholder for binds that used to call `noctalia msg <verb>` under
 * Hyprland. Does nothing at runtime; grep NOCTALIA_STUB for every spot that
 * still needs a real backend patched through, the argument being the old verb. */
#define NOCTALIA_STUB(verb) SHCMD("true # TODO(noctalia): " verb)

/* Raise/lower the default sink (capped at 100%), then nudge slstatus to redraw. */
#define VOLCMD(delta) "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " delta "; pkill -USR1 slstatus"

static const char *termcmd[]  = { "kitty", NULL };
/* kitty only honours initial_window_* when remember_window_size is off. The
 * app_id is matched by a floating rule above. */
static const char *floatterm[] = { "kitty", "--class", "floatterm", "-o", "remember_window_size=no",
                                   "-o", "initial_window_width=80c", "-o", "initial_window_height=20c", NULL };

#define SHIFT WLR_MODIFIER_SHIFT
#define CTRL  WLR_MODIFIER_CTRL
#define ALT   WLR_MODIFIER_ALT

/* Ported from home/modules/hyprland/binds.lua. dwl has no directional focus,
 * pseudotiling or pinning, so those are not carried over; focus n/u and i/e
 * (the Colemak left/up and right/down) walk the stack instead. Master/layout
 * binds are dwl-only and live on Ctrl, which Hyprland leaves free. */
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

	/* Launchers */
	{ MODKEY,                    XKB_KEY_space,       spawn,            SHCMD("wofi --show drun") },
	{ MODKEY,                    XKB_KEY_h,           spawn,            SHCMD("~/bin/binds-menu") },
	{ MODKEY,                    XKB_KEY_Return,      spawn,            {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_t,           spawn,            {.v = floatterm} },
	{ MODKEY|SHIFT,              XKB_KEY_t,           spawn,            SHCMD("hacky-tts-toggle") },
	{ MODKEY,                    XKB_KEY_grave,       spawn,            SHCMD("hacky-launcher-toggle") },
	{ MODKEY|SHIFT,              XKB_KEY_s,           spawn,            SHCMD("hyprshot -z --mode region --output-folder ~/Pictures/Screenshots") },
	{ MODKEY|SHIFT,              XKB_KEY_c,           spawn,            SHCMD("hyprpicker -qaf rgb") },
	{ MODKEY|SHIFT,              XKB_KEY_w,           spawn,            SHCMD("moonlight stream 'nico' 'desktop'") },
	{ MODKEY|SHIFT,              XKB_KEY_e,           spawn,            SHCMD("nautilus") },
	{ MODKEY,                    XKB_KEY_c,           spawn,            SHCMD("kitty zsh -i -c nvim") },
	{ MODKEY,                    XKB_KEY_b,           spawn,            SHCMD("zen-beta") },
	{ MODKEY,                    XKB_KEY_m,           spawn,            SHCMD("kitty zsh -i -c spotify_player") },
	{ MODKEY,                    XKB_KEY_d,           spawn,            SHCMD("kitty zsh -i -c concord") },

	/* Noctalia launchers */
	{ MODKEY,                    XKB_KEY_v,           spawn,            NOCTALIA_STUB("panel-toggle clipboard") },
	{ MODKEY,                    XKB_KEY_period,      spawn,            NOCTALIA_STUB("panel-toggle launcher \"/emo \"") },
	{ MODKEY,                    XKB_KEY_Tab,         spawn,            NOCTALIA_STUB("window-switcher") },
	{ MODKEY|SHIFT,              XKB_KEY_space,       spawn,            NOCTALIA_STUB("panel-toggle launcher \"/pan \"") },

	/* Noctalia panels & menus */
	{ MODKEY,                    XKB_KEY_a,           spawn,            NOCTALIA_STUB("panel-toggle control-center") },
	{ MODKEY,                    XKB_KEY_o,           spawn,            NOCTALIA_STUB("panel-toggle session") },
	{ MODKEY,                    XKB_KEY_w,           spawn,            NOCTALIA_STUB("panel-toggle control-center notifications") },
	{ MODKEY|ALT,                XKB_KEY_w,           spawn,            NOCTALIA_STUB("notification-dnd-toggle") },
	{ MODKEY,                    XKB_KEY_comma,       spawn,            NOCTALIA_STUB("settings-toggle") },
	{ MODKEY,                    XKB_KEY_k,           spawn,            NOCTALIA_STUB("panel-toggle control-center calendar") },

	/* Toggles. Shift+B is dwl's own bar, not Noctalia's. */
	{ MODKEY|SHIFT,              XKB_KEY_b,           togglebar,        {0} },
	{ MODKEY|SHIFT,              XKB_KEY_d,           spawn,            NOCTALIA_STUB("theme-mode-toggle") },
	{ MODKEY|SHIFT,              XKB_KEY_n,           spawn,            NOCTALIA_STUB("nightlight-toggle") },
	{ MODKEY|SHIFT,              XKB_KEY_i,           spawn,            NOCTALIA_STUB("caffeine-toggle") },

	/* Noctalia plugins */
	{ MODKEY|ALT,                XKB_KEY_s,           spawn,            NOCTALIA_STUB("plugin harveywuk/airpods:service all cycle-noise") },
	{ MODKEY|SHIFT,              XKB_KEY_r,           spawn,            NOCTALIA_STUB("plugin noctalia/screen_recorder:service all toggle") },

	/* Display filters */
	{ MODKEY|SHIFT,              XKB_KEY_g,           spawn,            SHCMD("hyprcrt-toggle") },

	/* Window management */
	{ MODKEY,                    XKB_KEY_f,           togglefullscreen, {0} },
	{ MODKEY|SHIFT,              XKB_KEY_f,           togglefloating,   {0} },
	{ MODKEY|SHIFT,              XKB_KEY_A,           toggleswallow,    {0} },
	{ MODKEY|CTRL,               XKB_KEY_a,           toggleautoswallow,{0} },

	/* Focus: Colemak n/i/u/e and the arrows, as in Hyprland */
	{ MODKEY,                    XKB_KEY_n,           focusstack,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_u,           focusstack,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_i,           focusstack,       {.i = +1} },
	{ MODKEY,                    XKB_KEY_e,           focusstack,       {.i = +1} },
	{ MODKEY,                    XKB_KEY_Left,        focusstack,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_Up,          focusstack,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_Right,       focusstack,       {.i = +1} },
	{ MODKEY,                    XKB_KEY_Down,        focusstack,       {.i = +1} },

	/* dwl-only: master area, layouts, monitors */
	{ MODKEY|CTRL,               XKB_KEY_n,           setmfact,         {.f = -0.05f} },
	{ MODKEY|CTRL,               XKB_KEY_i,           setmfact,         {.f = +0.05f} },
	{ MODKEY|CTRL,               XKB_KEY_o,           setopacity,       {.f = +0.1f} },
	{ MODKEY|CTRL|SHIFT,         XKB_KEY_O,           setopacity,       {.f = -0.1f} },
	{ MODKEY|CTRL,               XKB_KEY_u,           incnmaster,       {.i = +1} },
	{ MODKEY|CTRL,               XKB_KEY_e,           incnmaster,       {.i = -1} },
	{ MODKEY|CTRL,               XKB_KEY_Return,      zoom,             {0} },
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
	{ 0, XKB_KEY_XF86AudioMute,          spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; pkill -USR1 slstatus") },
	{ 0, XKB_KEY_XF86AudioMicMute,       spawn, NOCTALIA_STUB("mic-mute") },
	{ 0, XKB_KEY_XF86AudioPlay,          spawn, NOCTALIA_STUB("media toggle") },
	{ 0, XKB_KEY_XF86AudioStop,          spawn, NOCTALIA_STUB("media stop") },
	{ 0, XKB_KEY_XF86AudioPrev,          spawn, NOCTALIA_STUB("media previous") },
	{ 0, XKB_KEY_XF86AudioNext,          spawn, NOCTALIA_STUB("media next") },
	{ 0, XKB_KEY_XF86MonBrightnessUp,    spawn, NOCTALIA_STUB("brightness-up 5") },
	{ 0, XKB_KEY_XF86MonBrightnessDown,  spawn, NOCTALIA_STUB("brightness-down 5") },

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
	{ ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
	{ ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
	{ ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
	{ ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
};

static const Axis axes[] = {
	{ MODKEY, AxisUp,   spawn, SHCMD("volume-up_EXAMPLE") },
	{ MODKEY, AxisDown, spawn, SHCMD("volume-down_EXAMPLE") },
};

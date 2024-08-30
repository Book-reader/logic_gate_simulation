module electronics_game::sdl2::scancode;

const UNKNOWN = 0;

/**
 *  \name Usage page 0x07
 *
 *  These values are from usage page 0x07 (USB keyboard page).
 */
/* @{ */

const A = 4;
const B = 5;
const C = 6;
const D = 7;
const E = 8;
const F = 9;
const G = 10;
const H = 11;
const I = 12;
const J = 13;
const K = 14;
const L = 15;
const M = 16;
const N = 17;
const O = 18;
const P = 19;
const Q = 20;
const R = 21;
const S = 22;
const T = 23;
const U = 24;
const V = 25;
const W = 26;
const X = 27;
const Y = 28;
const Z = 29;

const NUM_1 = 30;
const NUM_2 = 31;
const NUM_3 = 32;
const NUM_4 = 33;
const NUM_5 = 34;
const NUM_6 = 35;
const NUM_7 = 36;
const NUM_8 = 37;
const NUM_9 = 38;
const NUM_0 = 39;

const RETURN = 40;
const ESCAPE = 41;
const BACKSPACE = 42;
const TAB = 43;
const SPACE = 44;

const MINUS = 45;
const EQUALS = 46;
const LEFTBRACKET = 47;
const RIGHTBRACKET = 48;
const BACKSLASH = 49; /* Located at the lower left of the return
  *   key on ISO keyboards and at the right end
  *   of the QWERTY row on ANSI keyboards.
  *   Produces REVERSE SOLIDUS (backslash) and
  *   VERTICAL LINE in a US layout, REVERSE
  *   SOLIDUS and VERTICAL LINE in a UK Mac
  *   layout, NUMBER SIGN and TILDE in a UK
  *   Windows layout, DOLLAR SIGN and POUND SIGN
  *   in a Swiss German layout, NUMBER SIGN and
  *   APOSTROPHE in a German layout, GRAVE
  *   ACCENT and POUND SIGN in a French Mac
  *   layout, and ASTERISK and MICRO SIGN in a
  *   French Windows layout.
  */
const NONUSHASH = 50; /* ISO USB keyboards actually use this code
  *   instead of 49 for the same key, but all
  *   OSes I've seen treat the two codes
  *   identically. So, as an implementor, unless
  *   your keyboard generates both of those
  *   codes and your OS treats them differently;
  *   you should generate const BACKSLASH
  *   instead of this code. As a user, you
  *   should not rely on this code because SDL
  *   will never generate it with most (all?)
  *   keyboards.
  */
const SEMICOLON = 51;
const APOSTROPHE = 52;
const GRAVE = 53; /* Located in the top left corner (on both ANSI
  *   and ISO keyboards). Produces GRAVE ACCENT and
  *   TILDE in a US Windows layout and in US and UK
  *   Mac layouts on ANSI keyboards, GRAVE ACCENT
  *   and NOT SIGN in a UK Windows layout, SECTION
  *   SIGN and PLUS-MINUS SIGN in US and UK Mac
  *   layouts on ISO keyboards, SECTION SIGN and
  *   DEGREE SIGN in a Swiss German layout (Mac:
  *   only on ISO keyboards), CIRCUMFLEX ACCENT and
  *   DEGREE SIGN in a German layout (Mac: only on
  *   ISO keyboards), SUPERSCRIPT TWO and TILDE in a
  *   French Windows layout, COMMERCIAL AT and
  *   NUMBER SIGN in a French Mac layout on ISO
  *   keyboards, and LESS-THAN SIGN and GREATER-THAN
  *   SIGN in a Swiss German, German, or French Mac
  *   layout on ANSI keyboards.
  */
const COMMA = 54;
const PERIOD = 55;
const SLASH = 56;

const CAPSLOCK = 57;

const F1 = 58;
const F2 = 59;
const F3 = 60;
const F4 = 61;
const F5 = 62;
const F6 = 63;
const F7 = 64;
const F8 = 65;
const F9 = 66;
const F10 = 67;
const F11 = 68;
const F12 = 69;

const PRINTSCREEN = 70;
const SCROLLLOCK = 71;
const PAUSE = 72;
const INSERT = 73; /* insert on PC, help on some Mac keyboards (but
   does send code 73, not 117) */
const HOME = 74;
const PAGEUP = 75;
const DELETE = 76;
const END = 77;
const PAGEDOWN = 78;
const RIGHT = 79;
const LEFT = 80;
const DOWN = 81;
const UP = 82;

const NUMLOCKCLEAR = 83; /* num lock on PC, clear on Mac keyboards
 */
const KP_DIVIDE = 84;
const KP_MULTIPLY = 85;
const KP_MINUS = 86;
const KP_PLUS = 87;
const KP_ENTER = 88;
const KP_1 = 89;
const KP_2 = 90;
const KP_3 = 91;
const KP_4 = 92;
const KP_5 = 93;
const KP_6 = 94;
const KP_7 = 95;
const KP_8 = 96;
const KP_9 = 97;
const KP_0 = 98;
const KP_PERIOD = 99;

const NONUSBACKSLASH = 100; /* This is the additional key that ISO
*   keyboards have over ANSI ones;
*   located between left shift and Y.
*   Produces GRAVE ACCENT and TILDE in a
*   US or UK Mac layout, REVERSE SOLIDUS
*   (backslash) and VERTICAL LINE in a
*   US or UK Windows layout, and
*   LESS-THAN SIGN and GREATER-THAN SIGN
*   in a Swiss German, German, or French
*   layout. */
const APPLICATION = 101; /* windows contextual menu, compose */
const POWER = 102; /* The USB document says this is a status flag;
   *   not a physical key - but some Mac keyboards
   *   do have a power key. */
const KP_EQUALS = 103;
const F13 = 104;
const F14 = 105;
const F15 = 106;
const F16 = 107;
const F17 = 108;
const F18 = 109;
const F19 = 110;
const F20 = 111;
const F21 = 112;
const F22 = 113;
const F23 = 114;
const F24 = 115;
const EXECUTE = 116;
const HELP = 117;/* AL Integrated Help Center */
const MENU = 118;/* Menu (show menu) */
const SELECT = 119;
const STOP = 120;/* AC Stop */
const AGAIN = 121;   /* AC Redo/Repeat */
const UNDO = 122;/* AC Undo */
const CUT = 123; /* AC Cut */
const COPY = 124;/* AC Copy */
const PASTE = 125;   /* AC Paste */
const FIND = 126;/* AC Find */
const MUTE = 127;
const VOLUMEUP = 128;
const VOLUMEDOWN = 129;
/* not sure whether there's a reason to enable these */
/* const LOCKINGCAPSLOCK = 130,  */
/* const LOCKINGNUMLOCK = 131, */
/* const LOCKINGSCROLLLOCK = 132, */
const KP_COMMA = 133;
const KP_EQUALSAS400 = 134;

const INTERNATIONAL1 = 135; /* used on Asian keyboards, see
footnotes in USB doc */
const INTERNATIONAL2 = 136;
const INTERNATIONAL3 = 137; /* Yen */
const INTERNATIONAL4 = 138;
const INTERNATIONAL5 = 139;
const INTERNATIONAL6 = 140;
const INTERNATIONAL7 = 141;
const INTERNATIONAL8 = 142;
const INTERNATIONAL9 = 143;
const LANG1 = 144;/* Hangul/English toggle */
const LANG2 = 145;/* Hanja conversion */
const LANG3 = 146;/* Katakana */
const LANG4 = 147;/* Hiragana */
const LANG5 = 148;/* Zenkaku/Hankaku */
const LANG6 = 149;/* reserved */
const LANG7 = 150;/* reserved */
const LANG8 = 151;/* reserved */
const LANG9 = 152;/* reserved */

const ALTERASE = 153;/* Erase-Eaze */
const SYSREQ = 154;
const CANCEL = 155; /* AC Cancel */
const CLEAR = 156;
const PRIOR = 157;
const RETURN2 = 158;
const SEPARATOR = 159;
const OUT = 160;
const OPER = 161;
const CLEARAGAIN = 162;
const CRSEL = 163;
const EXSEL = 164;

const KP_00 = 176;
const KP_000 = 177;
const THOUSANDSSEPARATOR = 178;
const DECIMALSEPARATOR = 179;
const CURRENCYUNIT = 180;
const CURRENCYSUBUNIT = 181;
const KP_LEFTPAREN = 182;
const KP_RIGHTPAREN = 183;
const KP_LEFTBRACE = 184;
const KP_RIGHTBRACE = 185;
const KP_TAB = 186;
const KP_BACKSPACE = 187;
const KP_A = 188;
const KP_B = 189;
const KP_C = 190;
const KP_D = 191;
const KP_E = 192;
const KP_F = 193;
const KP_XOR = 194;
const KP_POWER = 195;
const KP_PERCENT = 196;
const KP_LESS = 197;
const KP_GREATER = 198;
const KP_AMPERSAND = 199;
const KP_DBLAMPERSAND = 200;
const KP_VERTICALBAR = 201;
const KP_DBLVERTICALBAR = 202;
const KP_COLON = 203;
const KP_HASH = 204;
const KP_SPACE = 205;
const KP_AT = 206;
const KP_EXCLAM = 207;
const KP_MEMSTORE = 208;
const KP_MEMRECALL = 209;
const KP_MEMCLEAR = 210;
const KP_MEMADD = 211;
const KP_MEMSUBTRACT = 212;
const KP_MEMMULTIPLY = 213;
const KP_MEMDIVIDE = 214;
const KP_PLUSMINUS = 215;
const KP_CLEAR = 216;
const KP_CLEARENTRY = 217;
const KP_BINARY = 218;
const KP_OCTAL = 219;
const KP_DECIMAL = 220;
const KP_HEXADECIMAL = 221;

const LCTRL = 224;
const LSHIFT = 225;
const LALT = 226; /* alt, option */
const LGUI = 227; /* windows, command (apple), meta */
const RCTRL = 228;
const RSHIFT = 229;
const RALT = 230; /* alt gr, option */
const RGUI = 231; /* windows, command (apple), meta */

const MODE = 257;/* I'm not sure if this is really not covered
 *   by any of the above, but since there's a
 *   special KMOD_MODE for it I'm adding it here
 */

/* @} *//* Usage page 0x07 */

/**
 *  \name Usage page 0x0C
 *
 *  These values are mapped from usage page 0x0C (USB consumer page).
 *  See https://usb.org/sites/default/files/hut1_2.pdf
 *
 *  There are way more keys in the spec than we can represent in the
 *  current scancode range, so pick the ones that commonly come up in
 *  real world usage.
 */
/* @{ */

const AUDIONEXT = 258;
const AUDIOPREV = 259;
const AUDIOSTOP = 260;
const AUDIOPLAY = 261;
const AUDIOMUTE = 262;
const MEDIASELECT = 263;
const WWW = 264; /* AL Internet Browser */
const MAIL = 265;
const CALCULATOR = 266;  /* AL Calculator */
const COMPUTER = 267;
const AC_SEARCH = 268;   /* AC Search */
const AC_HOME = 269; /* AC Home */
const AC_BACK = 270; /* AC Back */
const AC_FORWARD = 271;  /* AC Forward */
const AC_STOP = 272; /* AC Stop */
const AC_REFRESH = 273;  /* AC Refresh */
const AC_BOOKMARKS = 274;/* AC Bookmarks */

/* @} *//* Usage page 0x0C */

/**
 *  \name Walther keys
 *
 *  These are values that Christian Walther added (for mac keyboard?).
 */
/* @{ */

const BRIGHTNESSDOWN = 275;
const BRIGHTNESSUP = 276;
const DISPLAYSWITCH = 277; /* display mirroring/dual display
   switch, video mode switch */
const KBDILLUMTOGGLE = 278;
const KBDILLUMDOWN = 279;
const KBDILLUMUP = 280;
const EJECT = 281;
const SLEEP = 282;   /* SC System Sleep */

const APP1 = 283;
const APP2 = 284;

/* @} *//* Walther keys */

/**
 *  \name Usage page 0x0C (additional media keys)
 *
 *  These values are mapped from usage page 0x0C (USB consumer page).
 */
/* @{ */

const AUDIOREWIND = 285;
const AUDIOFASTFORWARD = 286;

/* @} *//* Usage page 0x0C (additional media keys) */

/**
 *  \name Mobile keys
 *
 *  These are values that are often used on mobile phones.
 */
/* @{ */

const SOFTLEFT = 287; /* Usually situated below the display on phones and
  used as a multi-function feature key for selecting
  a software defined function shown on the bottom left
  of the display. */
const SOFTRIGHT = 288; /* Usually situated below the display on phones and
   used as a multi-function feature key for selecting
   a software defined function shown on the bottom right
   of the display. */
const CALL = 289; /* Used for accepting phone calls. */
const ENDCALL = 290; /* Used for rejecting phone calls. */

/* @} *//* Mobile keys */

/* Add any other keys here. */

const NUM_SCANCODES = 512; /* not a key, just marks the number of scancodes


module sdl2;

const INIT_TIMER =          0x00000001u;
const INIT_AUDIO =          0x00000010u;
const INIT_VIDEO =          0x00000020u;
const INIT_JOYSTICK =       0x00000200u;
const INIT_HAPTIC =         0x00001000u;
const INIT_GAMECONTROLLER = 0x00002000u;
const INIT_EVENTS =         0x00004000u;
const INIT_SENSOR =         0x00008000u;
const INIT_NOPARACHUTE =    0x00100000u;
const INIT_EVERYTHING = (
                         INIT_TIMER | INIT_AUDIO | INIT_VIDEO | INIT_EVENTS |
                         INIT_JOYSTICK | INIT_HAPTIC | INIT_GAMECONTROLLER | INIT_SENSOR
);

distinct SDLWindow = any*;
distinct SDLRenderer = any*;
distinct SDLFont = any*;
distinct SDLSurface = any*;
// distinct Texture = any*;
def SDLTexture = SDLInner_Texture*;
def SDLColor = char[<4>];
def SDLRect = int[<4>];

extern fn int init(int flags) @extern("SDL_Init");
extern fn int quit() @extern("SDL_Quit");
extern fn int ttf_init() @extern("TTF_Init");
extern fn int ttf_quit() @extern("TTF_Quit");
extern fn SDLWindow create_window(ZString title, int x, int y, int w, int h, uint flags) @extern("SDL_CreateWindow");
extern fn SDLRenderer create_renderer(SDLWindow window, int unknown_1, int unknown_2) @extern("SDL_CreateRenderer");
extern fn ZString get_error() @extern("SDL_GetError");
extern fn bool poll_event(SDLEvent* event) @extern("SDL_PollEvent");
extern fn void sdl_set_draw_color(SDLRenderer renderer, char r, char g, char b, char a) @extern("SDL_SetRenderDrawColor");
extern fn int sdl_get_draw_color(SDLRenderer renderer, char* r, char* g, char* b, char* a) @extern("SDL_GetRenderDrawColor");
extern fn int clear(SDLRenderer renderer) @extern("SDL_RenderClear");
extern fn int present(SDLRenderer renderer) @extern("SDL_RenderPresent");
extern fn int delay(uint ms) @extern("SDL_Delay");
extern fn int destroy_window(SDLWindow window) @extern("SDL_DestroyWindow");
extern fn int destroy_renderer(SDLRenderer renderer) @extern("SDL_DestroyRenderer");
extern fn int fill_rect(SDLRenderer renderer, SDLRect *rectangle) @extern("SDL_RenderFillRect");
extern fn SDLFont open_font(ZString name, int size) @extern("TTF_OpenFont");
extern fn SDLSurface render_text_solid(SDLFont font, ZString text, SDLColor color) @extern("TTF_RenderText_Solid");
extern fn SDLTexture create_texture_from_surface(SDLRenderer renderer, SDLSurface surface) @extern("SDL_CreateTextureFromSurface");
extern fn int render_copy(SDLRenderer renderer, SDLTexture texture, SDLRect* crop, SDLRect* size_and_pos) @extern("SDL_RenderCopy");
extern fn int free_surface(SDLSurface surface) @extern("SDL_FreeSurface");
extern fn int destroy_texture(SDLTexture texture) @extern("SDL_DestroyTexture");
extern fn int draw_line(SDLRenderer renderer, int x1, int y1, int x2, int y2) @extern("SDL_RenderDrawLine");
// TODO rewatch https://www.youtube.com/watch?v=sLWkUzbMhIU as it shows how to make a library to incluse in c3 instead of linking with system library

fn SDLColor get_draw_color(SDLRenderer renderer)
{
  char r, g, b, a;
  sdl_get_draw_color(renderer, &r, &g, &b, &a);
  return {r, g, b, a};
}

fn void set_draw_color(SDLRenderer renderer, SDLColor color)
{
  sdl_set_draw_color(renderer, color.r, color.g, color.b, color.a);
}

SDLFont font = null;

import std::io;

// TODO: some sort of rendering cache where it caches the generated texture pointer (not position) (it would also have to store the color) and stores it in a HashMap(<String, Texture>), then in the main function defer empty_string_cache()
fn void draw_text(SDLRenderer renderer, ZString text, int[<2>] pos, SDLColor color = {0xff, 0x00, 0xff, 0xff})
{
  if (!font)
  {
    font = open_font("0xProto-Regular.ttf", 16);
    if (!font)
    {
      io::printfn("Error while loading font: %s", get_error());
    }
    io::printn("Loaded font for the first time");
  }

  SDLSurface text_surface = render_text_solid(font, text, color);
  defer free_surface(text_surface);
  SDLTexture text_texture = create_texture_from_surface(renderer, text_surface);
  defer destroy_texture(text_texture);

  render_copy(renderer, text_texture, null, &&SDLRect {pos, text_texture.w, text_texture.h});
}

union SDLEvent
{
  uint type;                            /* Event type, shared with all events */
  // SDL_CommonEvent common;                 /* Common event data */
  // SDL_DisplayEvent display;               /* Display event data */
  // SDL_WindowEvent window;                 /* Window event data */
  SDLKeyboardEvent key;                  /* Keyboard event data */
  // SDL_TextEditingEvent edit;              /* Text editing event data */
  // SDL_TextEditingExtEvent editExt;        /* Extended text editing event data */
  // SDL_TextInputEvent text;                /* Text input event data */
  SDLMouseMotionEvent motion;            /* Mouse motion event data */
  SDLMouseButtonEvent button;            /* Mouse button event data */
  // SDL_MouseWheelEvent wheel;              /* Mouse wheel event data */
  // SDL_JoyAxisEvent jaxis;                 /* Joystick axis event data */
  // SDL_JoyBallEvent jball;                 /* Joystick ball event data */
  // SDL_JoyHatEvent jhat;                   /* Joystick hat event data */
  // SDL_JoyButtonEvent jbutton;             /* Joystick button event data */
  // SDL_JoyDeviceEvent jdevice;             /* Joystick device change event data */
  // SDL_JoyBatteryEvent jbattery;           /* Joystick battery event data */
  // SDL_ControllerAxisEvent caxis;          /* Game Controller axis event data */
  // SDL_ControllerButtonEvent cbutton;      /* Game Controller button event data */
  // SDL_ControllerDeviceEvent cdevice;      /* Game Controller device event data */
  // SDL_ControllerTouchpadEvent ctouchpad;  /* Game Controller touchpad event data */
  // SDL_ControllerSensorEvent csensor;      /* Game Controller sensor event data */
  // SDL_AudioDeviceEvent adevice;           /* Audio device event data */
  // SDL_SensorEvent sensor;                 /* Sensor event data */
  // SDL_QuitEvent quit;                     /* Quit request event data */
  // SDL_UserEvent user;                     /* Custom event data */
  // SDL_SysWMEvent syswm;                   /* System dependent window event data */
  // SDL_TouchFingerEvent tfinger;           /* Touch finger event data */
  // SDL_MultiGestureEvent mgesture;         /* Gesture event data */
  // SDL_DollarGestureEvent dgesture;        /* Gesture event data */
  // SDL_DropEvent drop;                     /* Drag and drop event data */

  /* This is necessary for ABI compatibility between Visual C++ and GCC.
       Visual C++ will respect the push pack pragma and use 52 bytes (size of
       SDL_TextEditingEvent, the largest structure for 32-bit and 64-bit
       architectures) for this union, and GCC will use the alignment of the
       largest datatype within the union, which is 8 bytes on 64-bit
       architectures.

       So... we'll add padding to force the size to be 56 bytes for both.

       On architectures where pointers are 16 bytes, this needs rounding up to
       the next multiple of 16, 64, and on architectures where pointers are
       even larger the size of SDL_UserEvent will dominate as being 3 pointers.
    */
  // Uint8 padding[sizeof(void *) <= 8 ? 56 : sizeof(void *) == 16 ? 64 : 3 * sizeof(void *)];
}
struct SDLKeyboardEvent
{
  uint type;        /* ::SDL_KEYDOWN or ::SDL_KEYUP */
  uint timestamp;   /* In milliseconds, populated using SDL_GetTicks() */
  uint windowID;    /* The window with keyboard focus, if any */
  char state;        /* ::SDL_PRESSED or ::SDL_RELEASED */
  char repeat;       /* Non-zero if this is a key repeat */
  char[2] padding;
  SDLKeysym keysym;  /* The key that was pressed or released */
}

struct SDLKeysym
{
  ushort scancode;      /* SDL physical key code - see ::SDL_Scancode for details */
  uint sym;            /* SDL virtual key code - see ::SDL_Keycode for details */
  char mod;                 /* current key modifiers */
  uint unused;
}

struct SDLMouseMotionEvent
{
  uint type;        /* ::SDL_MOUSEMOTION */
  uint timestamp;   /* In milliseconds, populated using SDL_GetTicks() */
  uint windowID;    /* The window with mouse focus, if any */
  uint which;       /* The mouse instance id, or SDL_TOUCH_MOUSEID */
  uint state;       /* The current button state */
  int x;           /* X coordinate, relative to window */
  int y;           /* Y coordinate, relative to window */
  int xrel;        /* The relative motion in the X direction */
  int yrel;        /* The relative motion in the Y direction */
}

struct SDLMouseButtonEvent
{
  uint type;        /* ::SDL_MOUSEBUTTONDOWN or ::SDL_MOUSEBUTTONUP */
  uint timestamp;   /* In milliseconds, populated using SDL_GetTicks() */
  uint windowID;    /* The window with mouse focus, if any */
  uint which;       /* The mouse instance id, or SDL_TOUCH_MOUSEID */
  char button;       /* The mouse button index */
  char state;        /* ::SDL_PRESSED or ::SDL_RELEASED */
  char clicks;       /* 1 for single-click, 2 for double-click, etc. */
  char padding1;
  int x;           /* X coordinate, relative to window */
  int y;           /* Y coordinate, relative to window */
}

// FIXME: in order to get a textures width and height I have to recreate its size in bytes in c3 instead of just usung an any pointer
struct SDLInner_Texture
{
  // TODO: replace with the actual struct members for better portability (currently won't work on 32 bit systems)
  char[8 + 4 + 4] _a;
  int w;
  int h;
  char[4 + 4 + 4 + 4 + 8 + 8 + 8 + 8 + 4 + 4 + 8 + 8 + 8 + 8 + 8] _b;
  // char[8 + ] _b;
}

module sdl2::mouse;

macro button(x)
{
  return (1 << ((x)-1));
}

const BUTTON_LEFT =     1;
const BUTTON_MIDDLE =   2;
const BUTTON_RIGHT =    3;
const BUTTON_X1 =       4;
const BUTTON_X2 =       5;
// const BUTTON_LMASK =    button(BUTTON_LEFT);
// const BUTTON_MMASK =    button(BUTTON_MIDDLE);
// const BUTTON_RMASK =    button(BUTTON_RIGHT);
// const BUTTON_X1MASK =   button(BUTTON_X1);
// const BUTTON_X2MASK =   button(BUTTON_X2);


module sdl2::event_type;

const FIRSTEVENT = 0;
const QUIT = 0x100;
const APP_TERMINATING = 0x101;
const APP_LOWMEMORY = 0x102;
const APP_WILLENTERBACKGROUND = 0x103;
const APP_DIDENTERBACKGROUND = 0x104;
const APP_WILLENTERFOREGROUND = 0x105;
const APP_DIDENTERFOREGROUND = 0x106;
const LOCALECHANGED = 0x107;
const DISPLAYEVENT = 0x150;
const WINDOWEVENT = 0x200;
const SYSWMEVENT = 0x201;
const KEYDOWN = 0x300;
const KEYUP = 0x301;
const TEXTEDITING = 0x302;
const TEXTINPUT = 0x303;

const MOUSEMOTION = 0x400;
const MOUSEBUTTONDOWN = 0x401;
const MOUSEBUTTONUP = 0x402;
const MOUSEWHEEL = 0x403;


// TODO: port the rest of the events
/*
SDL_KEYMAPCHANGED,          /* Keymap changed due to a system event such as an
                                     input language or keyboard layout change.
 */
    SDL_TEXTEDITING_EXT,       /* Extended keyboard text editing (composition) */

    /* Mouse events */
    SDL_MOUSEMOTION    = 0x400, /* Mouse moved */
    SDL_MOUSEBUTTONDOWN,        /* Mouse button pressed */
    SDL_MOUSEBUTTONUP,          /* Mouse button released */
    SDL_MOUSEWHEEL,             /* Mouse wheel motion */

    /* Joystick events */
    SDL_JOYAXISMOTION  = 0x600, /* Joystick axis motion */
    SDL_JOYBALLMOTION,          /* Joystick trackball motion */
    SDL_JOYHATMOTION,           /* Joystick hat position change */
    SDL_JOYBUTTONDOWN,          /* Joystick button pressed */
    SDL_JOYBUTTONUP,            /* Joystick button released */
    SDL_JOYDEVICEADDED,         /* A new joystick has been inserted into the system */
    SDL_JOYDEVICEREMOVED,       /* An opened joystick has been removed */
    SDL_JOYBATTERYUPDATED,      /* Joystick battery level change */

    /* Game controller events */
    SDL_CONTROLLERAXISMOTION  = 0x650, /* Game controller axis motion */
    SDL_CONTROLLERBUTTONDOWN,          /* Game controller button pressed */
    SDL_CONTROLLERBUTTONUP,            /* Game controller button released */
    SDL_CONTROLLERDEVICEADDED,         /* A new Game controller has been inserted into the system */
    SDL_CONTROLLERDEVICEREMOVED,       /* An opened Game controller has been removed */
    SDL_CONTROLLERDEVICEREMAPPED,      /* The controller mapping was updated */
    SDL_CONTROLLERTOUCHPADDOWN,        /* Game controller touchpad was touched */
    SDL_CONTROLLERTOUCHPADMOTION,      /* Game controller touchpad finger was moved */
    SDL_CONTROLLERTOUCHPADUP,          /* Game controller touchpad finger was lifted */
    SDL_CONTROLLERSENSORUPDATE,        /* Game controller sensor was updated */
    SDL_CONTROLLERUPDATECOMPLETE_RESERVED_FOR_SDL3,
    SDL_CONTROLLERSTEAMHANDLEUPDATED,  /* Game controller Steam handle has changed */

    /* Touch events */
    SDL_FINGERDOWN      = 0x700,
    SDL_FINGERUP,
    SDL_FINGERMOTION,

    /* Gesture events */
    SDL_DOLLARGESTURE   = 0x800,
    SDL_DOLLARRECORD,
    SDL_MULTIGESTURE,

    /* Clipboard events */
    SDL_CLIPBOARDUPDATE = 0x900, /* The clipboard or primary selection changed */

    /* Drag and drop events */
    SDL_DROPFILE        = 0x1000, /* The system requests a file open */
    SDL_DROPTEXT,                 /* text/plain drag-and-drop event */
    SDL_DROPBEGIN,                /* A new set of drops is beginning (NULL filename) */
    SDL_DROPCOMPLETE,             /* Current set of drops is now complete (NULL filename) */

    /* Audio hotplug events */
    SDL_AUDIODEVICEADDED = 0x1100, /* A new audio device is available */
    SDL_AUDIODEVICEREMOVED,        /* An audio device has been removed. */

    /* Sensor events */
    SDL_SENSORUPDATE = 0x1200,     /* A sensor was updated */

    /* Render events */
    SDL_RENDER_TARGETS_RESET = 0x2000, /* The render targets have been reset and their contents need to be updated */
    SDL_RENDER_DEVICE_RESET, /* The device has been reset and all textures need to be recreated */

    /* Internal events */
    SDL_POLLSENTINEL = 0x7F00, /* Signals the end of an event poll cycle */

    /** Events ::SDL_USEREVENT through ::SDL_LASTEVENT are for your use,
 *  and should be allocated with SDL_RegisterEvents()
 */
    SDL_USEREVENT    = 0x8000,

    /**
 *  This last event is only for bounding internal arrays
 */
    SDL_LASTEVENT    = 0xFFFF



*/

module sdl2::render_flags;

const SOFTWARE = 0x00000001;      /* The renderer is a software fallback */

const ACCELERATED = 0x00000002;      /* The renderer uses hardware
                                    acceleration */
const PRESENTVSYNC = 0x00000004;     /* Present is synchronized
                                    with the refresh rate */
const  TARGETTEXTURE = 0x00000008;     /* The renderer supports

# Attribution: https://github.com/msteele/mojo-sdl/tree/main
# WIP: Upgrading for mojo nightly 2024.8.1517 (ee6ccd9a)

from memory import UnsafePointer, OpaquePointer
from sys import ffi, info, simdwidthof


fn get_sdl_lib_path() -> String:
    if info.CompilationTarget.is_linux():
        var lib_path: String = "/usr/lib/x86_64-linux-gnu/libSDL2.so"
        try:
            with open("/etc/os-release", "r") as f:
                var release = f.read()
                if release.find("Ubuntu") < 0:
                    lib_path = "/usr/lib64/libSDL2.so"
        except:
            print("Can't detect Linux version")
        return lib_path
    if info.CompilationTarget.is_macos():
        return "/opt/homebrew/lib/libSDL2.dylib"
    return ""


alias SDL_PIXELTYPE_PACKED32 = 6
alias SDL_PACKEDORDER_RGBA = 4
alias SDL_PACKEDLAYOUT_8888 = 6


fn SDL_DEFINE_PIXELFORMAT(
    type: Int, order: Int, layout: Int, bits: Int, bytes: Int
) -> Int:
    return (
        (1 << 28)
        | ((type) << 24)
        | ((order) << 20)
        | ((layout) << 16)
        | ((bits) << 8)
        | ((bytes) << 0)
    )


alias SDL_PIXELFORMAT_RGBA8888 = SDL_DEFINE_PIXELFORMAT(
    SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4
)

alias SDL_TEXTUREACCESS_STREAMING = 1
alias SDL_TEXTUREACCESS_TARGET = 2

alias SDL_INIT_VIDEO = 0x00000020


@register_passable("trivial")
struct SDL_Window:
    pass


@register_passable("trivial")
struct SDL_Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32
    fn __init__(out self, x: Int32, y: Int32, w: Int32, h: Int32):
        self.x = x
        self.y = y
        self.w = w
        self.h = h


@register_passable("trivial")
struct SDL_PixelFormat:
    pass


@register_passable("trivial")
struct SDL_Renderer:
    pass


@register_passable("trivial")
struct SDL_Texture:
    pass

@register_passable("trivial")
struct SDL_DisplayMode:
    var format: UInt32
    var w: Int32
    var h: Int32
    var refresh_rate: Int32
    var driverdata: OpaquePointer
    fn __init__(out self):
        self.format = 0
        self.w = 0
        self.h = 0
        self.refresh_rate = 0
        self.driverdata = OpaquePointer()

@register_passable("trivial")
struct SDL_Color:
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    fn __init__(out self):
        self.r = 0
        self.g = 0
        self.b = 0
        self.a = 0
    fn __init__(out self, r: UInt8, g: UInt8, b: UInt8, a: UInt8):
        self.r = r
        self.g = g
        self.b = b
        self.a = a


@register_passable("trivial")
struct SDL_Surface:
    var flags: UInt32
    var format: UnsafePointer[SDL_PixelFormat]
    var w: Int32
    var h: Int32
    var pitch: Int32
    var pixels: UnsafePointer[UInt32]
    var userdata: UnsafePointer[Int8]
    var locked: Int32
    var list_blitmap: UnsafePointer[Int8]
    var clip_rect: SDL_Rect
    var map: UnsafePointer[Int8]
    var refcount: Int32


alias SDL_QUIT = 0x100

alias SDL_KEYDOWN = 0x300
alias SDL_KEYUP = 0x301

alias SDL_MOUSEMOTION = 0x400
alias SDL_MOUSEBUTTONDOWN = 0x401
alias SDL_MOUSEBUTTONUP = 0x402
alias SDL_MOUSEWHEEL = 0x403


@register_passable("trivial")
struct Keysym:
    var scancode: Int32
    var keycode: Int32
    var mod: UInt16
    var unused: UInt32

    fn __init__(out self):
        self.scancode = 0
        self.keycode = 0
        self.mod = 0
        self.unused = 0


@value
@register_passable("trivial")
struct MouseMotionEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var state: UInt32
    var x: Int32
    var y: Int32
    var xrel: Int32
    var yrel: Int32


@register_passable("trivial")
struct MouseButtonEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var button: UInt8
    var state: UInt8
    var clicks: UInt8
    var padding1: UInt8
    var x: Int32
    var y: Int32


@register_passable("trivial")
struct MouseWheelEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var x: Int32
    var y: Int32
    var direction: UInt32
    var preciseX: Float32
    var preciseY: Float32
    var mouseX: Int32
    var mouseY: Int32


@register_passable("trivial")
struct Keyevent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var state: UInt8
    var repeat: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var keysym: Keysym

    def __init__(out self):
        self.type = 0
        self.timestamp = 0
        self.windowID = 0
        self.state = 0
        self.repeat = 0
        self.padding2 = 0
        self.padding3 = 0
        self.keysym = Keysym()


@register_passable("trivial")
struct Event:
    var type: UInt32
    var _padding: SIMD[DType.uint8, 16]
    var _padding2: Int64
    var _padding3: Int64

    fn __init__(out self):
        self.type = 0
        self._padding = 0
        self._padding2 = 0
        self._padding3 = 0

    def as_keyboard(self) -> UnsafePointer[Keyevent]:
        return UnsafePointer(to=self).bitcast[Keyevent]()

    def as_mousemotion(self) -> UnsafePointer[MouseMotionEvent]:
        return UnsafePointer(to=self).bitcast[MouseMotionEvent]()

    def as_mousebutton(self) -> UnsafePointer[MouseButtonEvent]:
        return UnsafePointer(to=self).bitcast[MouseButtonEvent]()

    def as_mousewheel(self) -> UnsafePointer[MouseWheelEvent]:
        return UnsafePointer(to=self).bitcast[MouseWheelEvent]()


# SDL.h
alias c_SDL_Init = fn (w: Int32) -> Int32
alias c_SDL_Quit = fn () -> None

# SDL_video.h
alias c_SDL_CreateWindow = fn (
    UnsafePointer[UInt8], Int32, Int32, Int32, Int32, Int32
) -> UnsafePointer[SDL_Window]
alias c_SDL_DestroyWindow = fn (UnsafePointer[SDL_Window]) -> None
alias c_SDL_GetWindowSurface = fn (s: UnsafePointer[Int8]) -> UnsafePointer[
    SDL_Surface
]
alias c_SDL_UpdateWindowSurface = fn (s: UnsafePointer[Int8]) -> Int32

# SDL_pixels.h
alias c_SDL_MapRGB = fn (Int32, Int32, Int32, Int32) -> UInt32

# SDL_timer.h
alias c_SDL_Delay = fn (Int32) -> UInt32

# SDL_event.h
alias c_SDL_PollEvent = fn (UnsafePointer[Event]) -> Int32

# SDL_render.h
alias c_SDL_CreateRenderer = fn (
    UnsafePointer[SDL_Window], Int32, UInt32
) -> UnsafePointer[SDL_Renderer]
alias c_SDL_DestroyRenderer = fn (UnsafePointer[SDL_Renderer]) -> None

alias c_SDL_CreateWindowAndRenderer = fn (
    Int32,
    Int32,
    UInt32,
    UnsafePointer[UnsafePointer[Int8]],
    UnsafePointer[UnsafePointer[SDL_Renderer]],
) -> Int32
alias c_SDL_RenderDrawPoint = fn (
    UnsafePointer[SDL_Renderer], Int32, Int32
) -> Int32
alias c_SDL_RenderDrawRect = fn (
    r: UnsafePointer[SDL_Renderer], rect: UnsafePointer[SDL_Rect]
) -> Int32
alias c_SDL_RenderPresent = fn (s: UnsafePointer[SDL_Renderer]) -> Int32
alias c_SDL_RenderClear = fn (s: UnsafePointer[SDL_Renderer]) -> Int32
alias c_SDL_SetRenderDrawColor = fn (
    UnsafePointer[SDL_Renderer], UInt8, UInt8, UInt8, UInt8
) -> Int32
alias SDL_BlendMode = Int
alias c_SDL_SetRenderDrawBlendMode = fn (
    UnsafePointer[SDL_Renderer], SDL_BlendMode
) -> Int32
alias c_SDL_SetRenderTarget = fn (
    r: UnsafePointer[SDL_Renderer],
    # t: UnsafePointer[SDL_Texture]) -> Int32
    t: Int64,
) -> Int32

alias c_SDL_RenderCopy = fn (
    r: UnsafePointer[SDL_Renderer],
    t: UnsafePointer[SDL_Texture],
    s: UnsafePointer[SDL_Rect],
    d: UnsafePointer[SDL_Rect],
) -> Int32

# SDL_surface.h
alias c_SDL_FillRect = fn (UnsafePointer[SDL_Surface], Int64, UInt32) -> Int32


# texture
alias c_SDL_CreateTexture = fn (
    UnsafePointer[SDL_Renderer], UInt32, Int32, Int32, Int32
) -> UnsafePointer[SDL_Texture]
alias c_SDL_CreateTextureFromSurface = fn (
    UnsafePointer[SDL_Renderer], UnsafePointer[SDL_Surface]
) -> UnsafePointer[SDL_Texture]
alias c_SDL_DestroyTexture = fn (UnsafePointer[SDL_Texture]) -> None
alias c_SDL_LockTexture = fn (
    UnsafePointer[SDL_Texture],
    UnsafePointer[SDL_Rect],
    UnsafePointer[
        SIMD[DType.uint8, 1]
    ],  # Pixel data: We can't increase this from 1 as we don't know if SDL will guarantee that the bytes are aligned
    UnsafePointer[
        Int32
    ],  # Pitch (this value doesn't seem to be working - returning ptr to 0x400 which is not valid)
) -> Int32
alias c_SDL_UnlockTexture = fn (UnsafePointer[SDL_Texture]) -> None

alias c_SDL_GetWindowPosition = fn (
    UnsafePointer[SDL_Window],
    UnsafePointer[Int32],
    UnsafePointer[Int32]
) -> None
alias SDL_WINDOWPOS_UNDEFINED = 0x1FFF0000
alias SDL_WINDOWPOS_CENTERED = 0x2FFF0000
alias SDL_WINDOW_SHOWN = 0x00000004


# renderer
alias SDL_RENDERER_ACCELERATED = 0x00000002
# SDL_error.h
alias c_SDL_GetError = fn () -> UnsafePointer[UInt8]
alias c_SDL_SetWindowSize = fn(
    UnsafePointer[SDL_Window],
    Int32,
    Int32
) -> None
alias c_SDL_SetWindowTitle = fn(
    UnsafePointer[SDL_Window],
    UnsafePointer[UInt8]
) -> None
alias c_SDL_GetCurrentDisplayMode = fn(
    Int32,
    UnsafePointer[SDL_DisplayMode],
) -> None
alias c_SDL_QueryTexture = fn(
    UnsafePointer[SDL_Texture],
    UnsafePointer[UInt8], # make sure to be null
    UnsafePointer[UInt8],
    UnsafePointer[Int32], # w
    UnsafePointer[Int32] # h
) -> None



struct SDL:
    var Init: c_SDL_Init
    var Quit: c_SDL_Quit

    var CreateWindow: c_SDL_CreateWindow
    var DestroyWindow: c_SDL_DestroyWindow

    var GetWindowSurface: c_SDL_GetWindowSurface
    var UpdateWindowSurface: c_SDL_UpdateWindowSurface
    var CreateRenderer: c_SDL_CreateRenderer
    var DestroyRenderer: c_SDL_DestroyRenderer
    var CreateWindowAndRenderer: c_SDL_CreateWindowAndRenderer
    var RenderDrawPoint: c_SDL_RenderDrawPoint
    var RenderDrawRect: c_SDL_RenderDrawRect
    var SetRenderDrawColor: c_SDL_SetRenderDrawColor
    var RenderPresent: c_SDL_RenderPresent
    var RenderClear: c_SDL_RenderClear
    var CreateTexture: c_SDL_CreateTexture
    var CreateTextureFromSurface: c_SDL_CreateTextureFromSurface
    var DestroyTexture: c_SDL_DestroyTexture

    var LockTexture: c_SDL_LockTexture
    var UnlockTexture: c_SDL_UnlockTexture
    var SetRenderDrawBlendMode: c_SDL_SetRenderDrawBlendMode
    var SetRenderTarget: c_SDL_SetRenderTarget
    var RenderCopy: c_SDL_RenderCopy

    var MapRGB: c_SDL_MapRGB
    var FillRect: c_SDL_FillRect
    var Delay: c_SDL_Delay
    var PollEvent: c_SDL_PollEvent

    var GetError: c_SDL_GetError

    var GetWindowPosition: c_SDL_GetWindowPosition
    var SetWindowSize: c_SDL_SetWindowSize
    var SetWindowTitle: c_SDL_SetWindowTitle
    var GetCurrentDisplayMode: c_SDL_GetCurrentDisplayMode

    var QueryTexture: c_SDL_QueryTexture

    fn __init__(out self) raises:
        var lib_path = get_sdl_lib_path()
        var SDL = ffi.DLHandle(lib_path)

        self.Init = SDL.get_function[c_SDL_Init]("SDL_Init")
        self.Quit = SDL.get_function[c_SDL_Quit]("SDL_Quit")

        self.CreateWindow = SDL.get_function[c_SDL_CreateWindow](
            "SDL_CreateWindow"
        )
        self.DestroyWindow = SDL.get_function[c_SDL_DestroyWindow](
            "SDL_DestroyWindow"
        )

        self.GetWindowSurface = SDL.get_function[c_SDL_GetWindowSurface](
            "SDL_GetWindowSurface"
        )
        self.UpdateWindowSurface = SDL.get_function[c_SDL_UpdateWindowSurface](
            "SDL_UpdateWindowSurface"
        )

        self.CreateRenderer = SDL.get_function[c_SDL_CreateRenderer](
            "SDL_CreateRenderer"
        )
        self.DestroyRenderer = SDL.get_function[c_SDL_DestroyRenderer](
            "SDL_DestroyRenderer"
        )
        self.CreateWindowAndRenderer = SDL.get_function[
            c_SDL_CreateWindowAndRenderer
        ]("SDL_CreateWindowAndRenderer")
        self.RenderDrawPoint = SDL.get_function[c_SDL_RenderDrawPoint](
            "SDL_RenderDrawPoint"
        )
        self.RenderDrawRect = SDL.get_function[c_SDL_RenderDrawRect](
            "SDL_RenderDrawRect"
        )
        self.SetRenderDrawColor = SDL.get_function[c_SDL_SetRenderDrawColor](
            "SDL_SetRenderDrawColor"
        )
        self.RenderPresent = SDL.get_function[c_SDL_RenderPresent](
            "SDL_RenderPresent"
        )
        self.RenderClear = SDL.get_function[c_SDL_RenderClear](
            "SDL_RenderClear"
        )
        self.SetRenderDrawBlendMode = SDL.get_function[
            c_SDL_SetRenderDrawBlendMode
        ]("SDL_SetRenderDrawBlendMode")
        self.SetRenderTarget = SDL.get_function[c_SDL_SetRenderTarget](
            "SDL_SetRenderTarget"
        )
        self.RenderCopy = SDL.get_function[c_SDL_RenderCopy]("SDL_RenderCopy")

        self.CreateTexture = SDL.get_function[c_SDL_CreateTexture](
            "SDL_CreateTexture"
        )
        self.CreateTextureFromSurface = SDL.get_function[c_SDL_CreateTextureFromSurface](
            "SDL_CreateTextureFromSurface"
        )
        self.DestroyTexture = SDL.get_function[c_SDL_DestroyTexture](
            "SDL_DestroyTexture"
        )
        self.LockTexture = SDL.get_function[c_SDL_LockTexture](
            "SDL_LockTexture"
        )
        self.UnlockTexture = SDL.get_function[c_SDL_UnlockTexture](
            "SDL_UnlockTexture"
        )
        self.MapRGB = SDL.get_function[c_SDL_MapRGB]("SDL_MapRGB")
        self.FillRect = SDL.get_function[c_SDL_FillRect]("SDL_FillRect")
        self.Delay = SDL.get_function[c_SDL_Delay]("SDL_Delay")
        self.PollEvent = SDL.get_function[c_SDL_PollEvent]("SDL_PollEvent")

        self.GetError = SDL.get_function[c_SDL_GetError]("SDL_GetError")
        self.GetWindowPosition = SDL.get_function[c_SDL_GetWindowPosition]("SDL_GetWindowPosition")
        self.SetWindowSize = SDL.get_function[c_SDL_SetWindowSize]("SDL_SetWindowSize")
        self.SetWindowTitle = SDL.get_function[c_SDL_SetWindowTitle]("SDL_SetWindowTitle")
        self.GetCurrentDisplayMode = SDL.get_function[c_SDL_GetCurrentDisplayMode]("SDL_GetCurrentDisplayMode")
        self.QueryTexture = SDL.get_function[c_SDL_QueryTexture]("SDL_QueryTexture")

    fn get_sdl_error_as_string(self) -> String:
        var error_ptr = self.GetError()  # Call the function to get the error pointer

        if error_ptr == UnsafePointer[UInt8]():  # Check if the pointer is null
            return "Unknown error"

        var error_string = String(error_ptr[])
        return error_string

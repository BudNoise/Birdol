from memory import UnsafePointer, OpaquePointer
from sys import ffi, info, simdwidthof
import .sdl2
fn get_sdlttf_lib_path() -> String:
    if info.os_is_linux():
        var lib_path: String = "/usr/lib/x86_64-linux-gnu/libSDL2_ttf.so"
        try:
            with open("/etc/os-release", "r") as f:
                var release = f.read()
                if release.find("Ubuntu") < 0:
                    lib_path = "/usr/lib64/libSDL2_ttf.so"
        except:
            print("Can't detect Linux version")
        return lib_path
    if info.os_is_macos():
        return "/opt/homebrew/lib/libSDL2_ttf.dylib"
    return ""


alias c_TTF_Init = fn() -> Int32
alias c_TTF_WasInit = fn() -> Int32
alias c_TTF_Quit = fn() -> None

@fieldwise_init
struct TTF_Font(Copyable, Movable):
    pass

alias c_TTF_OpenFont = fn(
    UnsafePointer[UInt8], # file
    Int32 # ptsize
) -> UnsafePointer[TTF_Font]
alias c_TTF_OpenFontIndex = fn(
    UnsafePointer[UInt8], # file
    Int32, # ptsize
    Int32 # long index
) -> UnsafePointer[TTF_Font]
alias c_TTF_CloseFont = fn(UnsafePointer[TTF_Font]) -> None
alias c_TTF_FontLineSkip = fn(UnsafePointer[TTF_Font]) -> Int32

alias c_TTF_RenderTextSolid = fn(
    UnsafePointer[TTF_Font], # font
    UnsafePointer[UInt8], # string
    SDL_Color # color
) -> UnsafePointer[SDL_Surface]

alias c_TTF_RenderTextUNICODESolid = fn(
    UnsafePointer[TTF_Font], # font
    UnsafePointer[UInt16], # string
    SDL_Color # color
) -> UnsafePointer[SDL_Surface]

alias c_TTF_RenderTextUTF8Solid = fn(
    UnsafePointer[TTF_Font], # font
    UnsafePointer[UInt8], # string
    SDL_Color # color
) -> UnsafePointer[SDL_Surface]

alias c_TTF_RenderTextShaded = fn(
    UnsafePointer[TTF_Font], # font
    UnsafePointer[UInt8], # string
    SDL_Color, # fg 
    SDL_Color # bg
) -> UnsafePointer[SDL_Surface]

alias c_TTF_RenderTextBlended = fn(
    UnsafePointer[TTF_Font], # font
    UnsafePointer[UInt8], # string
    SDL_Color, # fg 
) -> UnsafePointer[SDL_Surface]

alias c_TTF_FontHeight = fn(
    UnsafePointer[TTF_Font], # font
) -> Int32

struct SDL_TTF:
    var TTF_Init: c_TTF_Init
    var TTF_WasInit: c_TTF_WasInit
    var TTF_Quit: c_TTF_Quit

    var TTF_OpenFont: c_TTF_OpenFont
    var TTF_OpenFontIndex: c_TTF_OpenFontIndex
    var TTF_CloseFont: c_TTF_CloseFont
    var TTF_FontLineSkip: c_TTF_FontLineSkip
    var TTF_FontHeight: c_TTF_FontHeight

    var TTF_RenderTextSolid: c_TTF_RenderTextSolid
    var TTF_RenderTextShaded: c_TTF_RenderTextShaded
    var TTF_RenderTextBlended: c_TTF_RenderTextBlended
    var TTF_RenderTextUNICODESolid: c_TTF_RenderTextUNICODESolid
    var TTF_RenderTextUTF8Solid: c_TTF_RenderTextUTF8Solid
    fn __init__(out self) raises:
        var lib_path = get_sdlttf_lib_path()
        var SDLTTF = ffi.DLHandle(lib_path)
        self.TTF_Init = SDLTTF.get_function[c_TTF_Init]("TTF_Init")
        self.TTF_WasInit = SDLTTF.get_function[c_TTF_WasInit]("TTF_WasInit")
        self.TTF_Quit = SDLTTF.get_function[c_TTF_Quit]("TTF_Quit")

        self.TTF_OpenFont = SDLTTF.get_function[c_TTF_OpenFont]("TTF_OpenFont")
        self.TTF_OpenFontIndex = SDLTTF.get_function[c_TTF_OpenFontIndex]("TTF_OpenFontIndex")
        self.TTF_CloseFont = SDLTTF.get_function[c_TTF_CloseFont]("TTF_CloseFont")

        self.TTF_RenderTextSolid = SDLTTF.get_function[c_TTF_RenderTextSolid]("TTF_RenderText_Solid")
        self.TTF_RenderTextShaded = SDLTTF.get_function[c_TTF_RenderTextShaded]("TTF_RenderText_Shaded")
        self.TTF_RenderTextBlended = SDLTTF.get_function[c_TTF_RenderTextBlended]("TTF_RenderText_Blended")

        self.TTF_RenderTextUNICODESolid = SDLTTF.get_function[c_TTF_RenderTextUNICODESolid]("TTF_RenderUNICODE_Solid")
        self.TTF_RenderTextUTF8Solid = SDLTTF.get_function[c_TTF_RenderTextUTF8Solid]("TTF_RenderUTF8_Solid")

        self.TTF_FontLineSkip = SDLTTF.get_function[c_TTF_FontLineSkip]("TTF_FontLineSkip")
        self.TTF_FontHeight = SDLTTF.get_function[c_TTF_FontHeight]("TTF_FontHeight")

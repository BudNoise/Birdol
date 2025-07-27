from .sdl2 import *
from .sdl2_ttf import *
from memory import UnsafePointer

struct GUIWin:
    var window: UnsafePointer[SDL_Window]
    var renderers: List[UnsafePointer[SDL_Renderer]]
    var curr_render_i: Int32
    var title: String
    var x: Int32
    var y: Int32

    var sdl: SDL
    var sdl_ttf: SDL_TTF
    var fonts: Dict[String, UnsafePointer[TTF_Font]]
    fn __init__(out self, name: String, w: Int, h: Int) raises:
        self.x = 1920 // 2
        self.y = 1080 // 2
        self.title = name
        self.renderers = List[UnsafePointer[SDL_Renderer]]()
        self.curr_render_i = 0
        self.fonts = Dict[String, UnsafePointer[TTF_Font]]()


        self.sdl = SDL()
        self.sdl_ttf = SDL_TTF()
        var res_code = self.sdl.Init(SDL_INIT_VIDEO)
        if res_code != 0:
            raise Error("Epic fail")
        _ = self.sdl_ttf.TTF_Init()
        self.fonts["default"] = self.sdl_ttf.TTF_OpenFont("boldfont.ttf".unsafe_ptr(), 24)
        self.window = self.sdl.CreateWindow(self.title.unsafe_ptr(), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, w, h, SDL_WINDOW_SHOWN) # yay
        self.renderers.append(self.sdl.CreateRenderer(self.window, -1, SDL_RENDERER_ACCELERATED))
    
    fn add_renderer(mut self) -> Int32:
        self.renderers.append(self.sdl.CreateRenderer(self.window, -1, SDL_RENDERER_ACCELERATED))
        return len(self.renderers) - 1

    fn set_curr_renderer(mut self, i: Int32):
        if i >= 0 and i < len(self.renderers):
            self.curr_render_i = i
        else:
            print("TRYING TO SET CURRENT RENDERER OUT OF BOUNDS")

    # window
    fn set_window_size(self, w: Int32, h: Int32):
        self.sdl.SetWindowSize(self.window, w, h)
    fn set_window_title(mut self, title: String):
        self.title = title
        self.sdl.SetWindowTitle(self.window, self.title.unsafe_ptr())

    # rendering
    fn set_draw_color(self, r: UInt8, g: UInt8, b: UInt8, a: UInt8):
        _ = self.sdl.SetRenderDrawColor(self.renderers[self.curr_render_i], r, g, b, a)
    fn clean_bg(self):
        _ = self.sdl.RenderClear(self.renderers[self.curr_render_i])
    fn render(self):
        _ = self.sdl.RenderPresent(self.renderers[self.curr_render_i])

    # coordinates
    fn update_coords(mut self):
        self.sdl.GetWindowPosition(self.window, UnsafePointer[Int32](to=self.x), UnsafePointer[Int32](to=self.y))

    # display mode
    fn get_current_display_mode(mut self) -> SDL_DisplayMode:
        var mode = SDL_DisplayMode()
        self.sdl.GetCurrentDisplayMode(0, UnsafePointer[SDL_DisplayMode](to=mode))
        return mode

    fn draw_text(self, str: String, x: Int32, y: Int32):
        var surf = self.sdl_ttf.TTF_RenderTextSolid(self.fonts["default"], 24)
        var tex = self.sdl.CreateTextureFromSurface(self.renderers[self.curr_render_i], surf)
# low quality zhar
from SDL2 import *
import Browser
import random
fn random_string(length: Int) -> String:
    var chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var result = ""
    for _ in range(length):
        var idx = random.random_si64(0, len(chars) - 1)
        result += chars[idx]
    return result
fn main() raises:
    var win = GUIWin("Birdol Browser", 1280, 720)
    var run = True
    var tab = Browser.create_tab(UnsafePointer[GUIWin](to=win)) 
    while run:
        var event: Event = Event()
        while win.sdl.PollEvent(UnsafePointer[Event](to=event)):
            if event.type == SDL_QUIT:
                run = False
        win.set_window_title(random_string(5))
        win.update_coords()
        win.set_draw_color(255, 255, 255, 255)
        win.clean_bg()
        win.render()
        _ = win.sdl.Delay(16)
    win.sdl.DestroyWindow(win.window)
    win.sdl.Quit()
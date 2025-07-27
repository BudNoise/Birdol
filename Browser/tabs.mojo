from SDL2 import *
from .website import *
from memory import UnsafePointer
struct Tab:
    var renderer: Int32 # relative to its window
    var window: UnsafePointer[GUIWin] # in case of popups, you can point to the main window or any other window in memory
    var scroll_y: Int
    var curr_website: Website
    fn __init__(out self, i: Int32, w: UnsafePointer[GUIWin]):
        self.curr_website = Website()
        self.renderer = i # set the Renderer to the inde
        self.window = w
        self.scroll_y = 0

    fn render(mut self) raises:
        var curr_y: Int32 = 100
        for node in self.curr_website.html_nodes:
            if node.type == 0: # plain text
                self.window[].draw_text(node.data["text"], 0, curr_y)
                curr_y += self.window[].get_text_height(node.data["text"])

fn create_tab(w: UnsafePointer[GUIWin]) raises -> Tab:
    if w == UnsafePointer[GUIWin](): # compare it with an empty pointer
        raise Error("invalid pointer")


    i = w[].add_renderer() # add a pipeline for the specified tab
    return Tab(i, w)
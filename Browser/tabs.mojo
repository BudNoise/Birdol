from SDL2 import *
from memory import UnsafePointer
struct Tab:
    var renderer: Int32 # relative to its window
    var window: UnsafePointer[GUIWin] # in case of popups, you can point to the main window or any other window in memory
    fn __init__(out self, i: Int32, w: UnsafePointer[GUIWin]):
        self.renderer = i # set the Renderer to the inde
        self.window = w

fn create_tab(w: UnsafePointer[GUIWin]) raises -> Tab:
    if w == UnsafePointer[GUIWin](): # compare it with an empty pointer
        raise Error("invalid pointer")


    i = w[].add_renderer() # add a pipeline for the specified tab
    return Tab(i, w)
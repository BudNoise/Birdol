from SDL2 import *
struct Tab:
    var Renderer: Int32 # relative to its window
    var Window: Pointer[GUIWin] # in case of popups
    fn __init__(out self, i: Int32, w: Pointer[GUIWin]):
        self.Renderer = i
        self.Window = w
# low quality zhar
from SDL2 import *
import Browser
import HTML
import JS
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
    var testnode = HTML.HTMLNode(0)
    testnode.data = {
        "text": 'new super mario bros'
    }
    var b = JS.JS_BytecodeFunc()
    b.bytecodes = [
        JS.create_bytecode(JS.JS_BytecodeType.LOAD_CONST, {"val": "-5"}),
        JS.create_bytecode(JS.JS_BytecodeType.PUSH_OP, {"val": "+"}),
        JS.create_bytecode(JS.JS_BytecodeType.LOAD_CONST, {"val": "8"}),
        JS.create_bytecode(JS.JS_BytecodeType.PUSH_OP, {"val": "-"}),
        JS.create_bytecode(JS.JS_BytecodeType.LOAD_CONST, {"val": "3"}),
        JS.create_bytecode(JS.JS_BytecodeType.STORE_RESULT, {"a": "a"}),
        JS.create_bytecode(JS.JS_BytecodeType.STORE_VAR, {"name": "jeff"}),

        # IF

        JS.create_bytecode(JS.JS_BytecodeType.RUN, {
            "block": "9_to_10",
            "type": "IF",
            "comparison": "jeff,E,0"
        }),

        JS.create_bytecode(JS.JS_BytecodeType.LOAD_CONST, {"val": "5"}),
        JS.create_bytecode(JS.JS_BytecodeType.STORE_VAR, {"name": "jeff"}),
    ]
    a = b.call()
    if a:
        print(a.value().num)
    HTML.parse_html("e4")
    tab.curr_website.push_node(testnode)
    while run:
        var event: Event = Event()
        while win.sdl.PollEvent(UnsafePointer[Event](to=event)):
            if event.type == SDL_QUIT:
                run = False
        win.update_coords()
        win.set_draw_color(255, 255, 255, 255)
        win.clean_bg()
        tab.render()
        win.render()
        _ = win.sdl.Delay(16)
    win.sdl.DestroyWindow(win.window)
    win.sdl.Quit()
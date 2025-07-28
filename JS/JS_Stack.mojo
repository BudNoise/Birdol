from .JS_Object import *
struct JS_Stack(Copyable, Movable):
    var Variables: Dict[String, JS_Object]
    var Pool: List[JS_Object] # like those push/pop assembly stuff
    fn __init__(out self):
        self.Variables = Dict[String, JS_Object]
        self.Pool = List[JS_Object]
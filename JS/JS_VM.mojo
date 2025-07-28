from .bytecode import *
from .JS_Stack import *
struct JS_VM:
    var funcs: Dict[String, JS_BytecodeFunc]
    var main: List[JS_Bytecode]
    var stack: JS_Stack
    fn __init__(out self):
        self.funcs = Dict[String, JS_BytecodeFunc]()
        self.main = List[JS_Bytecode]()
        self.stack = JS_Stack()
    
    fn run(mut self):
        pass
from .bytecode import *
@fieldwise_init
struct JS_Object(Copyable, Movable):
    alias OBJECT_INT = 0
    alias OBJECT_STRING = 1
    alias OBJECT_FUNC = 2
    var kind: Int

    var num: Float64
    var str: String
    var func: Optional[JS_BytecodeFunc]

    fn __init__(out self, num: Float64):
        self.kind = Self.OBJECT_INT
        self.num = num
        self.str = ""
        self.func = Optional[JS_BytecodeFunc](None)

    fn __init__(out self, bool: Bool):
        self.kind = Self.OBJECT_INT
        self.num = Int(bool)
        self.str = ""
        self.func = Optional[JS_BytecodeFunc](None)

    fn __init__(out self, str: String):
        self.kind = Self.OBJECT_STRING
        self.str = str
        self.num = 0
        self.func = Optional[JS_BytecodeFunc](None)

    fn __init__(out self, code: JS_BytecodeFunc):
        self.kind = SELF.OBJECT_FUNC
        self.str = ""
        self.num = 0
        self.func = Optional[JS_BytecodeFunc](code)
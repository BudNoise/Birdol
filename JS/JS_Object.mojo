from .bytecode import *
@fieldwise_init
struct JS_Object(Copyable, Movable):
    alias OBJECT_INT = 0
    alias OBJECT_STRING = 1
    alias OBJECT_FUNC = 2
    alias OBJECT_DICT = 3
    var kind: Int

    var num: Float64
    var str: String
    var func: Optional[JS_BytecodeFunc]
    var dict: Dict[String, JS_Object]

    fn __init__(out self, num: Float64):
        self.kind = Self.OBJECT_INT
        self.num = num
        self.str = ""
        self.func = Optional[JS_BytecodeFunc](None)
        self.dict = Dict[String, JS_Object]()

    fn __init__(out self, bool: Bool):
        self.kind = Self.OBJECT_INT
        self.num = Int(bool)
        self.str = ""
        self.func = Optional[JS_BytecodeFunc](None)
        self.dict = Dict[String, JS_Object]()

    fn __init__(out self, str: String):
        self.kind = Self.OBJECT_STRING
        self.str = str
        self.num = 0
        self.func = Optional[JS_BytecodeFunc](None)
        self.dict = Dict[String, JS_Object]()

    fn __init__(out self, code: JS_BytecodeFunc):
        self.kind = Self.OBJECT_FUNC
        self.str = ""
        self.num = 0
        self.func = Optional[JS_BytecodeFunc](code)
        self.dict = Dict[String, JS_Object]()

    fn __init__(out self, dict: Dict[String, JS_Object]):
        self.kind = Self.OBJECT_DICT
        self.str = ""
        self.num = 0
        self.func = Optional[JS_BytecodeFunc](None)
        self.dict = dict

    fn get_property(self, name: String) raises -> JS_Object:
        if self.kind != Self.OBJECT_DICT:
            raise "Trying to get a property from a variable that is neither a dict or a class"
        elif name not in self.dict:
            raise "Trying to get a property that doesn't exist"

        return self.dict[name]

    def print_properties(self):
        for prop in self.dict:
            print(prop, self.dict[prop].kind)

    fn set_property(mut self, name: String, value: JS_Object) raises:
        if self.kind != Self.OBJECT_DICT:
            raise "Trying to set a property on a non-dict"
        self.dict[name] = value
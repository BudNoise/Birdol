from .JS_VM import *
"""
LOAD_CONST 3
PUSH_OP +
LOAD_CONST 5
LOAD_RESULT
STORE_VAR jeff

RUN 6_TO_8 IF jeff,E,8
CALL PRINT jeff
LOAD_CONST 5
STORE_VAR jeff
RET
"""
@fieldwise_init
struct JS_BytecodeType:
    alias LOAD_CONST = 0
    alias PUSH_OP = 1
    alias STORE_RESULT = 2
    alias STORE_VAR = 3
    alias RET = 4
    alias RUN = 5
struct JS_Bytecode(Copyable, Movable):
    var type: Int
    var operand: Dict[String, String]
    fn __init__(out self, type: Int):
        self.type = type
        self.operand = Dict[String, String]()
fn create_bytecode(type: Int, operand: Dict[String, String]) -> JS_Bytecode:
    var bytecode = JS_Bytecode(type)
    bytecode.operand = operand
    return bytecode
struct JS_BytecodeFunc(Copyable, Movable):
    var bytecodes: List[JS_Bytecode]
    fn __init__(out self):
        self.bytecodes = List[JS_Bytecode]()

    fn push(mut self, bytecode: JS_Bytecode):
        self.bytecodes.append(bytecode)

    fn call(self) raises -> Optional[JS_Object]:
        var new_vm = JS_VM()
        new_vm.main = self.bytecodes

        new_vm.run()
        # now we check the last value in stack
        # because the RET bytecode pushes a value in stack
        var result = Optional[JS_Object](None)

        if len(new_vm.stack.Pool) > 0:
            result = Optional[JS_Object](new_vm.stack.Pool.pop()) # pop the stack and put it to an optional

        return result
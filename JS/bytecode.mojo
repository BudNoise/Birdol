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
    alias LOAD_VAR = 6
    alias CALL = 7
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
    var depth: Int # the compiletime depth, useful for the codegen, useless for the vm
    var dispatch_table: Dict[String, String] # ts maps function "inner" to it's actual name from compilation, like c++ mangles every single shit
    # fuck i hate c++
    # it is loaded in the stack like that so it's needed to use the nested funcs
    fn __init__(out self):
        self.bytecodes = List[JS_Bytecode]()
        self.depth = 0
        self.dispatch_table = Dict[String, String]()

    fn push(mut self, bytecode: JS_Bytecode):
        self.bytecodes.append(bytecode)

    fn call(self, parent: JS_VM, args: List[JS_Object] = List[JS_Object]()) raises -> Optional[JS_Object]:
        var new_vm = JS_VM()
        for name in self.dispatch_table:
            var mangled: String = self.dispatch_table[name]
            new_vm.stack.Variables[name] = parent.stack.get_var(mangled)
        new_vm.main = self.bytecodes

        new_vm.run(args)
        # now we check the last value in stack
        # because the RET bytecode pushes a value in stack
        var result = Optional[JS_Object](None)

        if len(new_vm.stack.Pool) > 0:
            result = Optional[JS_Object](new_vm.stack.Pool.pop()) # pop the stack and put it to an optional

        return result
fn print_bytecodes(ls: List[JS_Bytecode]) raises:
    var names = [
        "LOAD_CONST",
        "PUSH_OP",
        "STORE_RESULT",
        "STORE_VAR",
        "RET",
        "RUN",
        "LOAD_VAR",
        "CALL"
    ]
    for code in ls:
        name: String = names[code.type]
        var output: String = name

        for operando in code.operand:
            output += String(" {}: {}").format(operando, code.operand[operando])
        
        print(output)
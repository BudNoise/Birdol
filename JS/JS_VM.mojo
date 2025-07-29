from .bytecode import *
from .JS_Stack import *
@fieldwise_init
struct BinaryExpr(Copyable, Movable):
    var kind: String

    fn call(self, val1: JS_Object, val2: JS_Object) -> JS_Object:
        if self.kind == "+":
            return JS_Object(val1.num + val2.num)
        return JS_Object(0)
struct JS_VM:
    var funcs: Dict[String, JS_BytecodeFunc]
    var main: List[JS_Bytecode]
    var stack: JS_Stack
    fn __init__(out self):
        self.funcs = Dict[String, JS_BytecodeFunc]()
        self.main = List[JS_Bytecode]()
        self.stack = JS_Stack()
    
    fn run(mut self) raises:
        var current_operators = List[BinaryExpr]()
        for bytecode in self.main:
            if bytecode.type == 0: # LOAD_CONST
                # for now numbers
                self.stack.push(JS_Object(
                    Float64(bytecode.operand["val"])
                ))
            elif bytecode.type == 1: # PUSH_OP
                current_operators.append(
                    BinaryExpr(bytecode.operand["val"])
                )
            elif bytecode.type == 2: # STORE_RESULT
                # Perform the Arithmetic
                var new_val = self.stack.Pool[0] # first in the stack
                var current_i = 0
                for operator in current_operators:
                    new_val = operator.call(new_val, self.stack.Pool[current_i + 1])
                    current_i += 1

                self.stack.push(
                    new_val
                )
            elif bytecode.type == 3: # STORE_VAR
                self.stack.Variables[bytecode.operand["name"]] = self.stack.Pool[len(self.stack.Pool) - 1]
            elif bytecode.type == 4: # RET
                return
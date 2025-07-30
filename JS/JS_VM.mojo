from .bytecode import *
from .JS_Stack import *
alias DEBUG = True
@fieldwise_init
struct BinaryExpr(Copyable, Movable):
    alias template = fn(val1: JS_Object, val2: JS_Object) -> JS_Object

    var kind: String
    var funcs: Dict[String, Self.template]

    fn __init__(out self, kind: String):
        var funcs = Self.get_funcs()
        self.kind = kind
        self.funcs = funcs

    @staticmethod
    fn operator_plus(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num + val2.num)

    @staticmethod
    fn operator_minus(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num - val2.num)

    @staticmethod
    fn get_funcs() -> Dict[String, Self.template]:
        var dct = Dict[String, Self.template](power_of_two_initial_capacity=4)

        var expressions = [
            "+",
            "-"
        ]
        var funcs = [
            Self.operator_plus,
            Self.operator_minus
        ]
        for i in range(len(expressions)):
            dct[expressions[i]] = funcs[i]
        return dct
        
    fn call(self, val1: JS_Object, val2: JS_Object) raises -> JS_Object:
        if self.kind not in self.funcs:
            raise "Operator is NOT in the Table"
        return self.funcs[self.kind](val1, val2)
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
            if bytecode.type == JS_BytecodeType.LOAD_CONST: # just learned u could use aliases inside structs for doing fake enums
                # for now numbers
                self.stack.push(JS_Object(
                    Float64(bytecode.operand["val"])
                ))
            elif bytecode.type == JS_BytecodeType.PUSH_OP: # PUSH_OP
                current_operators.append(
                    BinaryExpr(bytecode.operand["val"])
                )
            elif bytecode.type == JS_BytecodeType.STORE_RESULT: # STORE_RESULT
                var current_val = self.stack.get_const(0)
                var i = 1
                for operator in current_operators:
                    var next_val = self.stack.get_const(i)
                    var res = operator.call(current_val, next_val)
                    if DEBUG:
                        print('Doing arithmetic "', current_val.num, operator.kind, next_val.num, "=", res.num, '"')
                    current_val = res
                    i += 1
                self.stack.Pool.clear() # Clear The Pool!
                self.stack.push(current_val)
                current_operators.clear()
            elif bytecode.type == JS_BytecodeType.STORE_VAR: # STORE_VAR
                self.stack.Variables[bytecode.operand["name"]] = self.stack.Pool[len(self.stack.Pool) - 1]
            elif bytecode.type == JS_BytecodeType.RET: # RET
                return
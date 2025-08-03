from .bytecode import *
from .JS_Stack import *
alias DEBUG = True
@fieldwise_init
struct BinaryExpr(Copyable, Movable):
    alias ExprTemplateFN = fn(val1: JS_Object, val2: JS_Object) -> JS_Object

    var kind: String
    var funcs: Dict[String, Self.ExprTemplateFN]

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
    fn operator_mul(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num * val2.num)

    @staticmethod
    fn operator_div(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num / val2.num)

    @staticmethod
    fn operator_pow(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num ** val2.num)
    
    @staticmethod
    fn operator_equal(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num == val2.num)

    @staticmethod
    fn operator_notequal(val1: JS_Object, val2: JS_Object) -> JS_Object:
        return JS_Object(val1.num != val2.num)

    @staticmethod
    fn get_funcs() -> Dict[String, Self.ExprTemplateFN]:
        var dct = Dict[String, Self.ExprTemplateFN](power_of_two_initial_capacity=4)

        var expressions = [
            "+",
            "-",
            "*",
            "/",
            "**",
            "==",
            "!="
        ]
        var funcs = [
            Self.operator_plus,
            Self.operator_minus,
            Self.operator_mul,
            Self.operator_div,
            Self.operator_pow,
            Self.operator_equal,
            Self.operator_notequal
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
    fn __copyinit__(out self, e: Self):
        self.funcs = e.funcs
        self.main = e.main
        self.stack = e.stack
    
    fn run(mut self) raises:
        var current_operators = List[BinaryExpr]()
        var succeed_blockentering = False
        var min_block, max_block = -1, -1 # main func
        var op_i = 0
        var was_in_block = False
        fn is_in_block() -> Bool:
            return op_i >= min_block and op_i < max_block
        fn if_can_run(comparison: String) raises -> Bool:
            var split2 = comparison.split(',')
            # right now it's only if variables           
            var Expr = BinaryExpr(String(split2[1]))
            var name = String(split2[0])
            var val = String(split2[2])
            var obj = self.stack.Variables[name]
            if DEBUG:
                print("Block has statement", name, Expr.kind, val)
            var result: Float64 = Expr.call(obj, JS_Object(Float64(val))).num

            return Bool(result)
        for bytecode in self.main:
            if is_in_block() and not succeed_blockentering: # subtle bug because it will skip the entire body if the statement is true
                op_i += 1
                continue

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
                self.stack.push(current_val)
                current_operators.clear()
            elif bytecode.type == JS_BytecodeType.STORE_VAR: # STORE_VAR
                var val = self.stack.last_const()
                self.stack.Variables[bytecode.operand["name"]] = val
                self.stack.Pool.clear()
            elif bytecode.type == JS_BytecodeType.RET: # RET
                return
            elif bytecode.type == JS_BytecodeType.RUN:
                was_in_block = True
                if DEBUG:
                    print("Found block")
                var data = bytecode.operand
                var split_block = bytecode.operand["block"].split("_")
                min_block = Int(split_block[0])
                max_block = Int(split_block[2])

                var type = bytecode.operand["type"]
                if type == "IF":
                    if DEBUG:
                        print("Block has an IF Statement")
                    var data2 = bytecode.operand["comparison"]
                    succeed_blockentering = if_can_run(data2)
                    if succeed_blockentering and DEBUG:
                        print("Block was succesful, can be run now")
                    elif DEBUG:
                        print("Block wasnt successful")
                elif type == "ELSE":
                    print("Block has an Else Statement")
                    succeed_blockentering = (not succeed_blockentering) and was_in_block
                    # was in block is a saveguard so you DONT write elses without parentes like ifs
                elif type == "ELIF":
                    var data2 = bytecode.operand["comparison"]
                    if DEBUG:
                        print("Block has an Else If Statement")
                    succeed_blockentering = (not succeed_blockentering) and if_can_run(data2)
                    if succeed_blockentering and DEBUG:
                        print("Block was succesful, can be run now")
                    elif DEBUG:
                        print("Block wasnt successful")
            elif bytecode.type == JS_BytecodeType.LOAD_VAR:
                var name = bytecode.operand["val"]
                var val = self.stack.get_var(name)

                self.stack.push(val)
            op_i += 1
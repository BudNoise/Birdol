from .bytecode import *
from .JS_Stack import *
from .JS_Compiler import *
from .standardlib import *
from time import *
alias DEBUG = False
alias MAX_FUNC_ARGS = 255
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
        bytecode_LOG = [create_bytecode(JS_BytecodeType.CALL, {
            "parent_count": "0",
            "arg_count": "-1",
            "name": "__STD_PRINT_LOG__",
        })]
        bytecode_WARN = [create_bytecode(JS_BytecodeType.CALL, {
            "parent_count": "0",
            "arg_count": "-1",
            "name": "__STD_PRINT_WARN__",
        })]
        bytecode_ERROR = [create_bytecode(JS_BytecodeType.CALL, {
            "parent_count": "0",
            "arg_count": "-1",
            "name": "__STD_PRINT_ERROR__",
        })]

        var bfunc, bfunc2, bfunc3 = JS_BytecodeFunc(), JS_BytecodeFunc(), JS_BytecodeFunc()
        bfunc.bytecodes = bytecode_LOG
        bfunc2.bytecodes = bytecode_WARN
        bfunc3.bytecodes = bytecode_ERROR
        self.stack.Variables["console"] = JS_Object({
            "log": JS_Object(bfunc),
            "warn": JS_Object(bfunc2),
            "error": JS_Object(bfunc3)
        })
    fn __copyinit__(out self, e: Self):
        self.funcs = e.funcs
        self.main = e.main
        self.stack = e.stack
    
    fn run(mut self, args: List[JS_Object] = []) raises:
        if DEBUG:
            print("Starting VM")
        var start = time.perf_counter_ns()
        for i in range(len(args)):
            var n = "__funcarg_" + String(i) + "__"
            if DEBUG:
                print("argumentous", n)
            self.stack.Variables[n] = args[i] # __funcarg_0__

        fn get_arg(i: Int) raises -> JS_Object:
            var n = "__funcarg_" + String(i) + "__"
            if n not in self.stack.Variables:
                raise "Trying to fetch an argument that doesn't exist"
            return self.stack.Variables[n]

        var INPUT_ARG_COUNT = len(args)

        
        var current_operators = List[BinaryExpr]()
        var succeed_blockentering = False
        var min_block, max_block = -1, -1 # main func
        var blockdepths = List[Dict[String, Int]]()
        var curr_depth = 0
        blockdepths.resize(10, {
            "min_block": -1,
            "max_block": -1,
            "in_while": False
        })
        var op_i = 0
        var was_in_block = False
        def is_in_block(depth: Int) -> Bool:
            return op_i >= blockdepths[depth]["min_block"] and op_i < blockdepths[depth]["max_block"]
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
        for i in range(len(self.main)):
            var bytecode: JS_Bytecode = self.main[i]
            if is_in_block(curr_depth) and op_i == blockdepths[curr_depth]["max_block"] and blockdepths[curr_depth]["is_while"]:
                op_i = blockdepths[curr_depth]["min_block"] - 1
                i = op_i
            elif is_in_block(curr_depth) and not succeed_blockentering: # subtle bug because it will skip the entire body if the statement is true
                op_i = blockdepths[curr_depth]["max_block"]
                i = op_i
                curr_depth -= 1


            if bytecode.type == JS_BytecodeType.LOAD_CONST: # just learned u could use aliases inside structs for doing fake enums
                # for now numbers
                self.stack.push(JS_Object(
                    Float64(bytecode.operand["val"])
                ))
            elif bytecode.type == JS_BytecodeType.PUSH_OP: # PUSH_OP
                current_operators.append(
                    BinaryExpr(bytecode.operand["val"])
                )
            elif bytecode.type == JS_BytecodeType.STORE_RESULT:
                while current_operators:
                    var right = self.stack.pop()   # top of stack
                    var left  = self.stack.pop()   # next
                    var op = current_operators.pop(0)  # or pop from front
                    var res = op.call(left, right)
                    if DEBUG:
                        print('Doing arithmetic "', left.num, op.kind, right.num, "=", res.num, '"')
                    self.stack.push(res)
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
                blockdepths[curr_depth]["min_block"] = Int(split_block[0])
                blockdepths[curr_depth]["max_block"] = Int(split_block[2])

                var type = bytecode.operand["type"]
                if type == "IF":
                    if DEBUG:
                        print("Block has an IF Statement")
                    var data2 = bytecode.operand["comparison"]
                    succeed_blockentering = if_can_run(data2)
                    curr_depth += Int(succeed_blockentering)
                    if succeed_blockentering and DEBUG:
                        print("Block was succesful, can be run now")
                    elif DEBUG:
                        print("Block wasnt successful")
                elif type == "ELSE":
                    print("Block has an Else Statement")
                    succeed_blockentering = (not succeed_blockentering) and was_in_block
                    curr_depth += Int(succeed_blockentering)
                    # was in block is a saveguard so you DONT write elses without parentes like ifs
                elif type == "ELIF":
                    var data2 = bytecode.operand["comparison"]
                    if DEBUG:
                        print("Block has an Else If Statement")
                    succeed_blockentering = (not succeed_blockentering) and if_can_run(data2)
                    curr_depth += Int(succeed_blockentering)
                    if succeed_blockentering and DEBUG:
                        print("Block was succesful, can be run now")
                    elif DEBUG:
                        print("Block wasnt successful")
                elif type == "WHILE":
                    var data2 = bytecode.operand["comparison"]
                    if DEBUG:
                        print("Block has an Else If Statement")
                    succeed_blockentering = if_can_run(data2)
                    curr_depth += Int(succeed_blockentering)
                    blockdepths[curr_depth]["is_while"] = succeed_blockentering
                    if succeed_blockentering and DEBUG:
                        print("Block was succesful, can be run now")
                    elif DEBUG:
                        print("Block wasnt successful")
            elif bytecode.type == JS_BytecodeType.LOAD_VAR:
                var name = bytecode.operand["val"]
                var val = self.stack.get_var(name)

                self.stack.push(val)
            elif bytecode.type == JS_BytecodeType.CALL:
                if DEBUG:
                    print("le_calleephone")
                var funcname = bytecode.operand["name"]
                if Int(bytecode.operand["parent_count"]) == 0:

                    var funcfuncs = STD.get_funcs()
                    if funcname in funcfuncs:
                        if DEBUG:
                            print("ohyeah")
                        # turn all of the string vars into JS_Objects
                        var count = Int(bytecode.operand["arg_count"])
                        var arg_list = List[JS_Object]()
                        for i in range(0, count):
                            var arg = bytecode.operand["arg_" + String(i)]
                            if arg in self.stack.Variables:
                                var val: JS_Object = self.stack.get_var(arg)
                                arg_list.append(val)
                            else:
                                var val: JS_Object = JS_Object(0.0)
                                # try to figure out if it's an int
                                if '"' not in arg:
                                    # it's an int
                                    val = JS_Object(Float64(arg))
                                else:
                                    val = JS_Object(arg[1:-1]) # first and second-to-last char
                            
                                arg_list.append(val)

                        if count == -1:
                            for i in range(0, MAX_FUNC_ARGS):
                                if DEBUG:
                                    print("Unc STILL got IT!")
                                var arg = String("__funcarg_{}__").format(i) # __funcarg_0__
                                if arg not in self.stack.Variables:
                                    break # we have passed all the args
                                arg_list.append(get_arg(i))
                                if DEBUG:
                                    print(get_arg(i).num)

                        funcfuncs[funcname](arg_list)
                    else:
                        if funcname in self.stack.Variables:
                            var obj = self.stack.get_var(funcname)
                            if obj.kind != JS_Object.OBJECT_FUNC: # SHOW ME YO WILLEH
                                raise "tf are you trying to do calling a non-function"
                            var func = obj.func.value()
                            func.call(self)
                else:
                    print("ah shit")
                    var count = Int(bytecode.operand["parent_count"])
                    var stackington = self.stack.Variables # console must be in the variables as a const
                    var previous_parent = stackington[bytecode.operand["parent_0"]]
                    for i in range(1, count):
                        var p = bytecode.operand[String("parent_{}").format(i)]
                        if DEBUG:
                            print(p)
                        if previous_parent.kind != JS_Object.OBJECT_DICT:
                            raise "Trying to get a property from a variable that is not a dict."
                        previous_parent = previous_parent.get_property(p)

                    var arg_count = Int(bytecode.operand["arg_count"])
                    var arg_list = List[JS_Object]()
                    if arg_count == -1:
                        for i in range(0, 255):
                            var arg = String("__funcarg_{}__").format(i) # __funcarg_0__
                            if arg not in self.stack.Variables:
                                break
                            arg_list.append(get_arg(i))
                            if DEBUG:
                                print("unc", get_arg(i).num)
                    else:
                        for i in range(arg_count):
                            var arg = String("arg_{}").format(i)
                            if DEBUG:
                                print(arg)
                            if arg not in bytecode.operand:
                                break
                            var name = bytecode.operand[arg]
                            var val: JS_Object = JS_Object(0.0)
                            if DEBUG:
                                print(name)

                            if name in self.stack.Variables:
                                val = self.stack.get_var(name)
                                if DEBUG:
                                    print("it exists")
                            else:
                                val = JS_Object(Float64(name))

                            arg_list.append(val)
                            if DEBUG:
                                print("unc dos", name)

                    var unc_still_func = previous_parent.get_property(bytecode.operand["name"])

                    if unc_still_func.kind != JS_Object.OBJECT_FUNC:
                        raise "Trying to call a variable that is not a function."

                    if unc_still_func.func:
                        var func = unc_still_func.func.value()
                        var res = func.call(self, arg_list)
                        if res:
                            pass # TODO: SET IT TO A VARIABLE

                            
                        
            op_i += 1
        var end = time.perf_counter_ns()
        print((end - start) / 1_000_000_000, "seconds")
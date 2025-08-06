from .JS_VM import *
from .bytecode import *

alias Tokens = List[String]

struct JS_Tokenizer:
    alias Normal = 0
    alias OnString = 1

    @staticmethod
    fn tokenize(str: String) raises -> List[String]:
        var toks = List[String]()
        var curr_tok = ""
        var mode = Self.Normal
        var i = 0
        var grp_1: List[String] = ["(", ",", ")", ";", "+", "-", "*", "/", "{", "}"]

        while i < len(str):
            var c = str[i]
            var verbose_c = String(c)
            var add_char = True

            if mode == Self.Normal:
                if c == " ":
                    add_char = False
                    if curr_tok != "":
                        toks.append(curr_tok)
                        curr_tok = ""
                elif i + 1 < len(str) and c == '*' and str[i + 1] == '*':
                    add_char = False
                    if curr_tok != "":
                        toks.append(curr_tok)
                        curr_tok = ""
                    toks.append("**")
                    i += 2  # skip both stars
                    continue
                elif verbose_c in grp_1:
                    add_char = False
                    if curr_tok != "":
                        toks.append(curr_tok)
                        curr_tok = ""
                    toks.append(verbose_c)

            if add_char:
                curr_tok += c

            i += 1

        if curr_tok != "":
            toks.append(curr_tok)

        return toks



alias JS_Scope = Dict[String, Bool]
alias JS_ScopeList = List[JS_Scope]
struct JS_Node(Copyable, Movable):
    alias Define_Variable = 0
    alias Start_Function = 1
    alias End_Function = 2
    var toks_list: List[String]
    var type: Int
    var data: Dict[String, String]
    fn __init__(out self, type: Int):
        self.type = type
        self.data = Dict[String, String]()
        self.toks_list = List[String]()
    fn __init__(out self, type: Int, data: Dict[String, String], toks_list: List[String]):
        self.type = type
        self.data = data
        self.toks_list = toks_list
struct JS_IR:
    var nodes: List[JS_Node]
    fn __init__(out self):
        self.nodes = List[JS_Node]()
    fn __copyinit__(out self, e: Self):
        self.nodes = e.nodes
    fn push(mut self, node: JS_Node):
        self.nodes.append(node)
alias UnknownVarName = "____UNKNOWN____"
struct JS_Parser:
    alias Def = 0
    alias VMaker = 1
    alias FCaller = 2
    alias FMaker = 3
    @staticmethod
    def parse(tokens: Tokens) -> JS_IR:
        var ir = JS_IR()
        var state = Self.Def
        var node_being_added = Optional[JS_Node](None)
        var VMaker_VARNAME = UnknownVarName
        var VMaker_VARTOKS = List[String]()
        var VMaker_WANTSVALUE = False

        var FuncMaker_I = 0
        var FuncMaker_NAME = UnknownVarName
        var on_Func = False
        for token in tokens:
            if state == Self.Def:
                var varmakergrp: List[String] = ["var", "let", "const"]
                if token in varmakergrp:
                    node_being_added = Optional[JS_Node](JS_Node(
                        JS_Node.Define_Variable,
                        {
                            "name": UnknownVarName,
                            "immut": "TRUE" if token == "const" else "FALSE",
                        },
                        List[String]()
                    ))
                    state = Self.VMaker
                    VMaker_VARTOKS.clear()
                    VMaker_VARNAME = UnknownVarName
                if token == "function":
                    node_being_added = Optional[JS_Node](JS_Node(
                        JS_Node.Start_Function,
                        {
                            "name": UnknownVarName,
                        },
                        List[String]()
                    ))
                    FuncMaker_I = 0
                    FuncMaker_NAME = UnknownVarName

                    state = Self.FMaker
                if token == "}" and on_Func:
                    ir.push(JS_Node(
                        JS_Node.End_Function,
                        {
                            "nothing": "",
                        },
                        List[String]()
                    ))
            elif state == Self.FMaker:
                FuncMaker_I += 1
                if FuncMaker_I == 1:
                    node_being_added.value().data["name"] = token
                    FuncMaker_NAME = token
                elif token != "(" and token != ")" and token != ",":
                    node_being_added.value().toks_list.append(token)
                elif token == ")":
                    ir.push(node_being_added.value())
                    node_being_added = Optional[JS_Node](None)
                    on_Func = True
            elif state == Self.VMaker:
                if not node_being_added:
                    raise "yo why the fuck is node nothing if it's supposed to have something on var maker"
                if VMaker_VARNAME == UnknownVarName:
                    VMaker_VARNAME = token
                    node_being_added.value().data["name"] = VMaker_VARNAME
                elif token == "=":
                    VMaker_WANTSVALUE = True
                elif token == ";":
                    node_being_added.value().toks_list = VMaker_VARTOKS
                    ir.push(node_being_added.value())
                    node_being_added = Optional[JS_Node](None)
                    state = Self.Def
                    VMaker_WANTSVALUE = False
                    VMaker_VARTOKS.clear()
                elif VMaker_WANTSVALUE:
                    VMaker_VARTOKS.append(token)
        return ir

            

struct JS_Codegen:
    @staticmethod
    def generate(ir: JS_IR) -> JS_VM:
        var vm = JS_VM()
        def is_operator(token: String) -> Bool:
            var operators: List[String] = ["+", "-", "/", "*", "**"]
            return token in operators
        def infix_to_postfix(tokens: List[String]) -> List[String]:
            var out = List[String]()
            var ops = List[String]()

            fn precedence(op: String) -> Int:
                if op == "+" or op == "-": return 1
                if op == "*" or op == "/": return 2
                if op == "**": return 3
                return 0

            for token in tokens:
                if not is_operator(token):
                    out.append(token)
                else:
                    if token == "**":
                        # right-associative
                        while ops and precedence(ops[-1]) > precedence(token):
                            out.append(ops.pop())
                    else:
                        # left-associative
                        while ops and precedence(ops[-1]) >= precedence(token):
                            out.append(ops.pop())
                    ops.append(token)

            while ops:
                out.append(ops.pop())
            return out
        var VariableScopeList = JS_ScopeList()
        for _ in range(255):
            VariableScopeList.append(JS_Scope()) # 255 is max depth in ECMAScript
        var FunctionScopeList = List[JS_BytecodeFunc]() # first is main, a scope it will reset every time a function is ended and be pushed to a funclist
        FunctionScopeList.append(JS_BytecodeFunc())
        var FunctionNameList = List[String]()
        FunctionNameList.append("main")
        var FuncList = Dict[String, JS_BytecodeFunc]()
        var Current_Depth = 0 # Main Func Depth

        def push_to_depth(mut scopelist: List[JS_BytecodeFunc], depth: Int, bytecode: JS_Bytecode):
            scopelist[depth].push(bytecode)
        
        def start_function(mut FunctionScopeList: List[JS_BytecodeFunc], mut i: Int, name: String):
            FunctionScopeList.append(JS_BytecodeFunc())
            i = len(FunctionScopeList) - 1
            FunctionNameList.append(name)
        
        def pop_function(mut FunctionScopeList: List[JS_BytecodeFunc], mut i: Int) -> (JS_BytecodeFunc, String):
            i -= 1
            return (FunctionScopeList.pop(), FunctionNameList.pop())

        def generate_function_id()

        for node in ir.nodes:
            if node.type == JS_Node.Define_Variable:
                var val_toks = node.toks_list
                var name = node.data.get("name", "")
                if len(val_toks) == 1:
                    var val = val_toks[0]
                    if val.isdigit():
                        push_to_depth(FunctionScopeList, Current_Depth,
                        create_bytecode(
                            JS_BytecodeType.LOAD_CONST,
                            {
                                "val": val
                            }
                        ))
                else:
                    for tok in infix_to_postfix(val_toks):
                        if not is_operator(tok):
                            push_to_depth(FunctionScopeList, Current_Depth,
                                create_bytecode(
                                JS_BytecodeType.LOAD_CONST,
                                {
                                    "val": tok
                                }
                            ))
                        else:
                            push_to_depth(FunctionScopeList, Current_Depth,
                                create_bytecode(
                                JS_BytecodeType.PUSH_OP,
                                {
                                    "val": tok
                                }
                            ))
                    push_to_depth(FunctionScopeList, Current_Depth,
                        create_bytecode(
                            JS_BytecodeType.STORE_RESULT,
                            {
                                "a": ""
                            }
                    ))
                        

                push_to_depth(FunctionScopeList, Current_Depth,
                    create_bytecode(
                        JS_BytecodeType.STORE_VAR,
                        {
                            "name": name
                        }
                ))
                VariableScopeList[Current_Depth][name] = True
            elif node.type == JS_Node.Start_Function:
                start_function(FunctionScopeList, Current_Depth, node.data["name"])
            elif node.type == JS_Node.End_Function:
                var popped = pop_function(FunctionScopeList, Current_Depth)
                FuncList[popped[1]] = popped[0]
            
        vm.main = FunctionScopeList[0].bytecodes
        for name in FuncList: # TODO: add funcs to FuncList from the Scope. maybe when a node is end function
            var func = FuncList[name]

            vm.stack.Variables[name] = JS_Object(func)
        return vm
                        
struct JS_Compiler:
    @staticmethod
    def compile(str: String) -> JS_VM:
        var tokens = JS_Tokenizer.tokenize(str)
        var ir = JS_Parser.parse(tokens)
        var vm = JS_Codegen.generate(ir)
        return vm
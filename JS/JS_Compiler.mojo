from .JS_VM import *
from .bytecode import *

alias Tokens = List[String]
struct JS_Tokenizer:
    alias Normal = 0
    alias OnString = 1

    @staticmethod
    fn tokenize(str: String) raises -> List[String]:
        var curr_tok = ""
        var mode = Self.Normal 
        var toks = List[String]()

        var grp_1: List[String] = ["(", ",", ")", ";", "+", "-", "*", "/", "**", "{", "}"]
        for c in str:
            var add_char = True
            if mode == Self.Normal:
                if c == " ":
                    add_char = False
                    if curr_tok != "":
                        toks.append(curr_tok)
                        curr_tok = ""
                elif String(c) in grp_1:
                    add_char = False
                    toks.append(curr_tok)
                    toks.append(String(c))
                    curr_tok = ""
            if add_char:
                curr_tok += c
        if curr_tok != "":
            toks.append(curr_tok)
        var output = "["
        for tok in toks:
            output += tok
            output += ", "
        output += "]"
        print(output)
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
            elif state == Self.VMaker:
                if not node_being_added:
                    raise "yo why the fuck is node nothing if it's supposed to have something on var maker"
                if VMaker_VARNAME == "":
                    VMaker_VARNAME = token
                    node_being_added.value().data["name"] = VMaker_VARNAME
                    node_being_added.value().toks_list = VMaker_VARTOKS
                elif token == "=":
                    VMaker_WANTSVALUE = True
                elif token == ";":
                    ir.push(node_being_added.value())
                    node_being_added = Optional[JS_Node](None)
                    state = Self.Def
                    VMaker_WANTSVALUE = False
                    VMaker_VARTOKS.clear()
                elif VMaker_WANTSVALUE:
                    VMaker_VARTOKS.append(token)


            

struct JS_Codegen:
    @staticmethod
    fn compile(ir: JS_IR) -> JS_VM:
        var VariableScopeList = JS_ScopeList()
        for _ in range(255):
            VariableScopeList.append(JS_Scope()) # 255 is max depth in ECMAScript
        var FunctionScopeList = List[JS_BytecodeFunc]() # first is main, a scope it will reset every time a function is ended and be pushed to a funclist
        FunctionScopeList.append(JS_BytecodeFunc())
        var FuncList = Dict[String, JS_BytecodeFunc]()
        var Current_Depth = 0 # Main Func Depth

        def push_to_depth(mut scopelist: List[JS_BytecodeFunc], depth: Int, bytecode: JS_Bytecode):
            scopelist[depth].push(bytecode)

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

                push_to_depth(FunctionScopeList, Current_Depth,
                    create_bytecode(
                        JS_BytecodeType.STORE_VAR,
                        {
                            "name": name
                        }
                ))
                        

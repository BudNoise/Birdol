from .JS_VM import *
from .bytecode import *

struct JS_Tokenizer:
    alias Normal = 0
    alias OnString = 1

    @staticmethod
    fn tokenize(str: String) raises -> List[String]:
        var curr_tok = ""
        var mode = Self.Normal 
        var toks = List[String]()
        for c in str:
            var add_char = True
            if mode == Self.Normal:
                if c == " ":
                    add_char = False
                    if curr_tok != "":
                        toks.append(curr_tok)
                        curr_tok = ""
                elif c in ["(", ",", ")", ";"]:
                    add_char = False
                    toks.append(curr_tok)
                    toks.append(String(c))
                    curr_tok = ""
            if add_char:
                curr_tok += c
        if curr_tok != "":
            toks.append(curr_tok)
        return toks

alias JS_Scope = Dict[String, Bool]
alias JS_ScopeList = List[JS_Scope]

fn print_scopelist(ls: JS_ScopeList) raises:
    for scope in ls:
        for name in scope:
            print(name, scope[name])

struct JS_Compiler:
    alias Default = 0
    alias VarMaker = 1
    alias FunctionCaller = 2
    fn __init__(out self):
        pass
    
    @staticmethod
    fn compile(str: String, mut scopelist: JS_ScopeList) raises -> JS_VM:
        if not scopelist:
            var imdead = JS_Scope()
            scopelist.append(imdead)
        fn token_is_not_operator(token: String) -> Bool:
            return token not in BinaryExpr.get_funcs()
        var vm = JS_VM()
        var pushing_to = JS_BytecodeFunc()
        var result = JS_Tokenizer.tokenize(str)

        var state = Self.Default
        var i = 0
        var var_name = ""
        var var_tokens = List[String]()

        var Token_Lister = Dict[String, List[String]]()

        fn var_exists(name: String, owned scplist: JS_ScopeList) raises -> Bool:
            scplist.reverse()
            for scope in scplist:      
                if name in scope:
                    return True
            return False


        fn infix_to_postfix(tokens: List[String]) -> List[String]:
            var out = List[String]()
            var ops = List[String]()

            fn precedence(op: String) -> Int:
                if op == "+" or op == "-":
                    return 1
                if op == "*" or op == "/":
                    return 2
                return 0

            for token in tokens:
                if token_is_not_operator(token):
                    out.append(token)
                else:
                    while ops and precedence(ops[-1]) >= precedence(token):
                        out.append(ops.pop())
                    ops.append(token)

            while ops:
                out.append(ops.pop())

            return out

        var arg_list = 0
        var token_i = 0
        for token in result:
            if (token == "var" or token == "let") and state != Self.VarMaker:
                # start var maker
                state = Self.VarMaker
                i = 0
                var_tokens.clear()
                var_name = ""   
            elif (token == "(") and state != Self.FunctionCaller:
                state = Self.FunctionCaller
                TokenLister["func_name"] = result[token_i] - 1 # get the very next token 
                var_tokens.clear()
            if state == Self.FunctionCaller:
                i += 1
                if i == 2:
                    TokenLister["func_name"] = token
                elif token == "(":
                    var_tokens.clear()
                elif token != ",":
                    var_tokens.append(token)
                    arg_list += 1
                elif token == ")"
                    var foodtothebytecodepusher = Dict[String, String]()
                    foodtothebytecodepusher["arg_count"] = String(arg_list)
                    foodtothebytecodepusher["name"] = TokenLister["func_name"]
                    var arg_i = 0
                    for vtoken in var_tokens:
                        foodtothebytecodepusher["arg_" + String(arg_i)] = vtoken
                        arg_i += 1

                    pushing_to.push(create_bytecode(
                        JS_BytecodeType.CALL,
                        foodtothebytecodepusher
                    ))
                    TokenLister.clear()
                    var_tokens.clear()
                    state = Self.Default
            if state == Self.VarMaker:
                i += 1
                if i == 2:
                    var_name = token
                elif i >= 4 and token != ";": # SKIP THE =
                    var_tokens.append(token)
                if token == ";":
                    # make the bytecode for it
                    for vtoken in infix_to_postfix(var_tokens):
                        if token_is_not_operator(vtoken):  
                            var result = var_exists(String(vtoken), scopelist)      
                            if result:
                                pushing_to.push(create_bytecode(
                                    JS_BytecodeType.LOAD_VAR,
                                    {
                                        "val": vtoken
                                    }
                                ))
                            else:
                                pushing_to.push(create_bytecode(
                                    JS_BytecodeType.LOAD_CONST,
                                    {
                                        "val": vtoken
                                    }
                                ))
                        else:
                            pushing_to.push(
                                create_bytecode(
                                    JS_BytecodeType.PUSH_OP,
                                    {
                                        "val": vtoken
                                    }
                                )
                            )
                    pushing_to.push(create_bytecode(
                        JS_BytecodeType.STORE_RESULT,
                        {
                            "a":""
                        }
                    ))

                    pushing_to.push(create_bytecode(
                        JS_BytecodeType.STORE_VAR,
                        {
                            "name": var_name
                        }
                    ))
                    scopelist[0][var_name] = True

                    var_tokens.clear()
                    var_name = ""
                    i = 0
                    state = Self.Default
            token_i += 1
        vm.main = pushing_to.bytecodes
        print_bytecodes(vm.main)
        return vm
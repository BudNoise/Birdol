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
    alias FunctionMaker = 3
    fn __init__(out self):
        pass

    @staticmethod
    fn compile_func_call(name: String, args: List[String]) -> JS_BytecodeFunc:
        var code = JS_BytecodeFunc()

        var food = Dict[String, String]()

        for i in range(len(args)):
            food["arg_" + String(i)] = args[i]

        food["arg_count"] = String(len(args))

        food["parent_count"] = 0

        food["name"] = name

        code.push(
            create_bytecode(
                JS_BytecodeType.CALL,
                food
            )
        )

        return code
    
    @staticmethod
    fn compile(str: String, mut scopelist: JS_ScopeList) raises -> JS_VM:
        if not scopelist:
            var imdead = JS_Scope()
            scopelist.append(imdead)
        fn token_is_not_operator(token: String) -> Bool:
            return token not in BinaryExpr.get_funcs()
        var vm = JS_VM()
        var pushing_to = JS_BytecodeFunc()
        var pushing_to_scopelist = List[JS_BytecodeFunc]()
        pushing_to_scopelist.append(JS_BytecodeFunc())
        var pushing_to_i = 0
        var result = JS_Tokenizer.tokenize(str)

        var state = Self.Default
        var i = 0
        var var_name = ""
        var var_tokens = List[String]()

        var TokenLister = Dict[String, String]()

        fn var_exists(name: String, owned scplist: JS_ScopeList) raises -> Bool:
            for i in range(len(scplist) - 1, -1, -1):      
                scope = scplist[i]
                if name in scope:
                    return True
            return False

        fn add_new_depth(mut pushing_to_scopelist: List[JS_BytecodeFunc], mut pushing_to_i: Int):
            pushing_to_scopelist.append(JS_BytecodeFunc())
            pushing_to_i = len(pushing_to_scopelist) - 1

        fn push_to_currdepth(mut pushing_to_scopelist: List[JS_BytecodeFunc], bytecode: JS_Bytecode):
            pushing_to_scopelist[pushing_to_i].push(
                bytecode
            )


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

        var started_ARGS = False
        var function_ARGS = List[String]() # to translate like my_arg into __funcarg_0__ because its the first argument 
        var on_Function = False
        var Functions = Dict[String, JS_BytecodeFunc]()
        var CURRFUNCNAME = ""
        var arg_list = 0
        var token_i = 0
        var parent_list = List[String]()
        for token in result:
            if (token == "var" or token == "let") and state != Self.VarMaker:
                # start var maker
                state = Self.VarMaker
                i = 0
                var_tokens.clear()
                var_name = ""   
            elif (token == "function") and state != Self.FunctionMaker:
                state = Self.FunctionMaker
                arg_list = 0
                var_tokens.clear()
                var name = result[token_i + 1] # function, name, (
                CURRFUNCNAME = name
            elif (token == "(") and state != Self.FunctionCaller and state != Self.FunctionMaker:
                state = Self.FunctionCaller
                arg_list = 0
                var name = result[token_i - 1]
                var unc = name.split(".")
                for n in unc:
                    parent_list.append(String(n))
                parent_list = parent_list[0:-1]
                TokenLister["func_name"] = String(unc[-1]) # get the previous token which is the name 
                var_tokens.clear()
            if state == Self.Default:
                if token == "{" and on_Function:
                    add_new_depth(pushing_to_scopelist, pushing_to_i)
                elif token == "}":
                    on_Function = False

                    Functions[CURRFUNCNAME] = pushing_to_scopelist[pushing_to_i]
                    _ = pushing_to_scopelist.pop()
                    pushing_to_i -= 1
            elif state == Self.FunctionMaker:
                var the_novartokens: List[String] = [",", ")", "{", "}"]
                if token == "(":
                    started_ARGS = True
                elif token != "," and token != ")" and token not in the_novartokens:
                    var_tokens.append(token)
                elif token == ")":
                    function_ARGS = var_tokens
                    # TODO: add a pushing_to list like if it was a depth, where 0 is
                    # the main func and 1 may be this function or even more if it's inside something else
                    var_tokens.clear()                
                    on_Function = True
                    state = Self.Default
            elif state == Self.FunctionCaller:
                if token == ")":
                    food = {
                        "arg_count": String(arg_list),
                        "parent_count": String(len(parent_list)),
                        "name": TokenLister["func_name"]
                    }
                    var arg_i, p_i = 0, 0
                    for vtoken in var_tokens:
                        food["arg_" + String(arg_i)] = vtoken
                        arg_i += 1
                    for parent in parent_list:
                        food["parent_" + String(p_i)] = parent
                        p_i += 1

                    push_to_currdepth( pushing_to_scopelist, create_bytecode(
                        JS_BytecodeType.CALL,
                        food
                    ))
                    parent_list.clear()
                    TokenLister.clear()
                    var_tokens.clear()
                    state = Self.Default
                elif token != "," and token != "(":
                    var_tokens.append(token)
                    arg_list += 1
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
                                push_to_currdepth( pushing_to_scopelist, create_bytecode(
                                    JS_BytecodeType.LOAD_VAR,
                                    {
                                        "val": vtoken
                                    }
                                ))
                            else:
                                push_to_currdepth( pushing_to_scopelist, create_bytecode(
                                    JS_BytecodeType.LOAD_CONST,
                                    {
                                        "val": vtoken
                                    }
                                ))
                        else:
                            push_to_currdepth( pushing_to_scopelist,
                                create_bytecode(
                                    JS_BytecodeType.PUSH_OP,
                                    {
                                        "val": vtoken
                                    }
                                )
                            )
                    push_to_currdepth( pushing_to_scopelist, create_bytecode(
                        JS_BytecodeType.STORE_RESULT,
                        {
                            "a":""
                        }
                    ))

                    push_to_currdepth( pushing_to_scopelist, create_bytecode(
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
        vm.main = pushing_to_scopelist[0].bytecodes
        for name in Functions:
            vm.stack.Variables[name] = JS_Object(Functions[name])
        return vm
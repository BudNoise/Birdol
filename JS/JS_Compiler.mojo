from .JS_VM import *

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
                elif c == ";":
                    add_char = False
                    toks.append(curr_tok)
                    toks.append(String(c))
                    curr_tok = ""
            if add_char:
                curr_tok += c
        if curr_tok != "":
            toks.append(curr_tok)
        return toks


            



struct JS_Compiler:
    alias Default = 0
    alias VarMaker = 1
    fn __init__(out self):
        pass
    
    @staticmethod
    fn compile(str: String) raises -> JS_VM:
        fn token_is_not_operator(token: String) -> Bool:
            return token not in BinaryExpr.get_funcs()
        var vm = JS_VM()
        var pushing_to = JS_BytecodeFunc()
        var result = JS_Tokenizer.tokenize(str)

        var state = Self.Default
        var i = 0
        var var_name = ""
        var var_tokens = List[String]()

        for token in result:
            if (token == "var" or token == "let") and state != Self.VarMaker:
                # start var maker
                state = Self.VarMaker    
            if state == Self.VarMaker:
                i += 1
                if i == 2:
                    var_name = token
                elif i >= 4 and token != ";": # SKIP THE =
                    var_tokens.append(token)

                if token == ";":
                    # make the bytecode for it
                    for vtoken in var_tokens:
                        if token_is_not_operator(vtoken):
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

                    var_tokens = []
                    var_name = ""
                    i = 0
        vm.main = pushing_to.bytecodes
        return vm
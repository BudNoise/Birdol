from .JS_VM import *

struct JS_Tokenizer:
    alias Normal = 0
    alias OnString = 1

    @staticmethod
    fn tokenize(str: String) -> List[Dict[String, String]]:
        var curr_tok = ""
        var mode = Self.Normal 
        var toks = List[Dict[String, String]]()
        fn add_tok():
            toks.append(curr_tok)
            curr_tok = ""
        for c in str.codepoints():
            var add_char = True
            if c == Codepoint(UInt8(' ')):
                if mode == Normal:
                    add_char = False
                    add_tok()
        return toks


            



struct JS_Compiler:
    fn __init__(out self):
        pass
    
    fn compile(self) -> JS_VM:
        var vm = JS_VM()
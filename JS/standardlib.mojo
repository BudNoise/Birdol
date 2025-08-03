from .JS_Object import *
fn native_print(objs: List[JS_Object]):
    var output = ""
    for obj in objs:
        if obj.kind == 0:
            output += String(obj.num)

        output += " "
    print(output)



alias STDLibTemplateFN = fn(args: List[JS_Object])

alias STDLIBType = Dict[String, STDLibTemplateFN]

struct STD:
    @staticmethod
    fn get_funcs() -> STDLIBType:
        var funcs = STDLIBType()

        funcs["print"] = native_print

        return funcs

    alias funcs = STD.get_funcs()



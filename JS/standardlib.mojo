from .JS_Object import *

fn native_print(objs: List[JS_Object]):
    var output = "Log: "
    for obj in objs:
        if obj.kind == 0:
            output += String(obj.num)

        output += " "
    print(output)

fn native_warn(objs: List[JS_Object]):
    var output = "Warning: "
    for obj in objs:
        if obj.kind == 0:
            output += String(obj.num)

        output += " "
    print(output)

fn native_error(objs: List[JS_Object]):
    var output = "Error: "
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

        funcs["__STD_PRINT_LOG__"] = native_print
        funcs["__STD_PRINT_WARN__"] = native_warn
        funcs["__STD_PRINT_ERROR__"] = native_error

        return funcs

    alias funcs = STD.get_funcs()



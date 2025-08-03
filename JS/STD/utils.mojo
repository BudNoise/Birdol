from .JS import *
fn native_print(objs: List[JS_Object]):
    var output = ""
    for obj in objs:
        if obj.kind == 0:
            output += obj.num

        output += " "
    print(output)
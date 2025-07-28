from .JS_VM import *
struct JS_Bytecode(Copyable, Movable):
    pass
struct JS_BytecodeFunc(Copyable, Movable):
    var bytecodes: List[JS_Bytecode]
    fn __init__(out self):
        self.bytecodes = List[JS_Bytecode]()

    fn call(mut self) -> Optional[JS_Object]:
        var new_vm = JS_VM()
        new_vm.main = self.bytecodes
        new_vm.run()
        # now we check the last value in stack
        # because the RET bytecode pushes a value in stack
        var result = Optional[JS_Object](None)

        if len(new_vm.stack.Pool) > 0:
            result = Optional[JS_Object](new_vm.stack.Pool.pop()) # pop the stack and put it to an optional

        return result
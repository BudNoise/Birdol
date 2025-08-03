from JS import *
fn main() raises:
    var main_vm = JS_VM.JS_VM()
    var scopelist = JS_Compiler.JS_ScopeList()
    while True:
        var code = input('JS_REPL > ')
        if code == "exit":
            break
        var new_vm = JS_Compiler.JS_Compiler.compile(code, scopelist)
        main_vm.main = new_vm.main
        main_vm.run()
        JS_VM.print_bytecodes(main_vm.main)
        main_vm.stack.dump()
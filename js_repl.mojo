from JS import *
fn main() raises:
    var main_vm = JS_VM.JS_VM()
    var scopelist = JS_Compiler.JS_ScopeList()
    while True:
        var new_vm = JS_Compiler.JS_Compiler.compile(input('JS_REPL > '), scopelist)
        main_vm.main = new_vm.main
        main_vm.run()
        JS_VM.print_bytecodes(main_vm.main)
        main_vm.stack.dump()
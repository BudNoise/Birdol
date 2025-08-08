from JS import *
fn main() raises:
    var main_vm = JS_VM.JS_VM()
    var scopelist = JS_Compiler.JS_ScopeList()
    def compile(code: String):
        var new_vm = JS_Compiler.JS_Compiler.compile(code)
        main_vm.main = new_vm.main
        main_vm.stack.Variables.update(new_vm.stack.Variables)
        JS_VM.print_bytecodes(main_vm.main)
        main_vm.run()
        main_vm.stack.dump()
    while True:
        var code = input('JS_REPL > ')
        var args = code.split(" ")
        var name = args[0]
        if name == "exit":
            break
        elif name == "help":
            print("Volokto: JS Runtime made in Mojo")
            print("""
            exit: exits the repl
            compile <file>: compiles the file and runs it
            """)
        elif name == "compile":
            if len(args) == 1:
                print("File not specified")
            else:
                for i in range(1, len(args)):
                    with open(args[i], 'r') as f:
                        var code = f.read()
                        compile(code)

        else:
            compile(code)
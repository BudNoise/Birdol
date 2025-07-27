alias BType = {
    "Load_Const": 0,
    "Load_Var": 1,
    "Call_Func": 2,
}
struct Bytecode(Copyable, Movable):
    var type: Int32
    var data: Dict[String, String]
struct JS_IR:
    var codes: List[Bytecode]
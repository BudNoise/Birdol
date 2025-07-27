@fieldwise_init
struct JS_Node(Copyable, Movable):
    var childs: List[JS_Node]
    fn __init__(out self):
        self.childs = List[JS_Node]()
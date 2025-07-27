from .js_node import *
@fieldwise_init
struct JS_AST:
    var nodes: List[JS_Node]
    fn __init__(out self):
        self.nodes = List[JS_Node]()
    fn push_node(mut self, node: JS_Node):
        self.nodes.append(node)
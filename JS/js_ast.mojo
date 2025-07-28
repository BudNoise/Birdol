from .js_node import *
struct JS_AST:
    var initial_node: JS_Node
    fn run(self):
        var top_level = self.initial_node
        var curr_node = top_level

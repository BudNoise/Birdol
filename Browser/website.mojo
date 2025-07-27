from HTML import *
struct Website:
    var html_nodes: List[HTMLNode]
    fn __init__(out self):
        self.html_nodes = List[HTMLNode]()
    
    fn push_node(mut self, node: HTMLNode):
        self.html_nodes.append(node)
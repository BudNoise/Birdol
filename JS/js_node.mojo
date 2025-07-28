struct JS_Node:
    alias Nullish_JSNode_Pointer = UnsafePointer[JS_Node]() # alias is like const

    var left: UnsafePointer[JS_Node]
    var right: UnsafePointer[JS_Node]
    fn __init__(out self):
        self.left = UnsafePointer[JS_Node]()
        self.right = UnsafePointer[JS_Node]()

    fn __copyinit__(out self, ex: Self):
        self.left = ex.left
        self.right = ex.right

    fn __moveinit__(out self, owned src: Self):
        self.left = src.left
        self.right = src.right

        src.left = src.Nullish_JSNode_Pointer
        src.right = src.Nullish_JSNode_Pointer

    fn left_is_valid(self) -> Bool:
        return self.left != self.Nullish_JSNode_Pointer # compare with empty pointer
    
    fn right_is_valid(self) -> Bool:
        return self.right != self.Nullish_JSNode_Pointer # compare with empty pointer
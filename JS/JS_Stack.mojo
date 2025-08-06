from .JS_Object import *
struct JS_Stack(Copyable, Movable):
    var Variables: Dict[String, JS_Object]
    var Pool: List[JS_Object] # like those push/pop assembly stuff
    fn __init__(out self):
        self.Variables = Dict[String, JS_Object]()
        self.Pool = List[JS_Object]()

    fn dump(self) raises:
        print("Constants in the Stack Pool:")
        for obj in self.Pool:
            print("  Object with value:", obj.num)
        print("Variables in the Stack:")
        for obj2 in self.Variables:
            print("  Object with name", obj2, "with value", self.Variables[obj2].num)
    fn push(mut self, obj: JS_Object):
        self.Pool.append(obj)
    fn pop(mut self) -> JS_Object:
        return self.Pool.pop()

    fn first_const(self) -> JS_Object:
        return self.Pool[0]

    fn get_var(self, name: String) raises -> JS_Object:
        if name not in self.Variables:
            raise "Trying to access a Variable that doesn't exist."
        return self.Variables[name]
    fn get_const(self, ind: Int) raises -> JS_Object:
        if ind < 0 or ind >= len(self.Pool):
            raise "wtf are you trying to do, getting out of bounds buddy?"
        return self.Pool[ind]

    fn last_const(self) -> JS_Object:
        return self.Pool[len(self.Pool) - 1]
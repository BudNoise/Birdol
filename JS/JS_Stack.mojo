from .JS_Object import *
struct JS_Stack(Copyable, Movable):
    var Variables: Dict[String, JS_Object]
    var Pool: List[JS_Object] # like those push/pop assembly stuff
    fn __init__(out self):
        self.Variables = Dict[String, JS_Object]()
        self.Pool = List[JS_Object]()

    fn push(mut self, obj: JS_Object):
        self.Pool.append(obj)

    fn first_const(self) -> JS_Object:
        return self.Pool[0]

    fn get_const(self, ind: Int) raises -> JS_Object:
        if ind < 0 or ind >= len(self.Pool):
            raise "wtf are you trying to do, getting out of bounds buddy?"
        return self.Pool[ind]

    fn last_const(self) -> JS_Object:
        return self.Pool[len(self.Pool) - 1]
@fieldwise_init
struct JS_Object(Copyable, Movable):
    var kind: Int

    var num: Float64
    var str: String

    fn __init__(out self, num: Float64):
        self.kind = 0
        self.num = num
        self.str = ""

    fn __init__(out self, bool: Bool):
        self.kind = 0
        self.num = Int(bool)
        self.str = ""

    fn __init__(out self, str: String):
        self.kind = 1
        self.str = str
        self.num = 0
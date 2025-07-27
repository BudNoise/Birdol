@fieldwise_init # make copy and move for me
# 0 - Display Text, Data: Text = "hi i'm textier"
struct HTMLNode(Copyable, Movable):
    var type: UInt8
    var data: Dict[String, String]

    fn __init__(out self, type: UInt8):
        self.type = type
        self.data = Dict[String, String]()

    fn __copyinit__(out self, e: Self):
        self.type = e.type
        self.data = e.data

    fn __moveinit__(out self, owned src: Self):
        self.type = src.type
        self.data = src.data
        src.type = 0
        src.data = Dict[String, String]()
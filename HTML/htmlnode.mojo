@fieldwise_init # make copy and move for me
struct HTMLNode:
    var type: UInt8
    var data: Dict[String, String]

    fn __init__(out self, type: UInt8):
        self.type = type
        self.data = Dict[String, String]()
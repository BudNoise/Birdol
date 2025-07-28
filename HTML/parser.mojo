from .htmlnode import *
fn parse_html(html: String) raises:
    var head = List[HTMLNode]()
    var body = List[HTMLNode]()

    for c in html.codepoints():
        if c == Codepoint.ord('4'):
            print("ee")
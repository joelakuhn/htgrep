require "./dom.cr";
require "./css.cr";
require "./css-parser.cr"

# h1
def make_h1_selector() : Selector
    return Selector.new("h1", [
        CompoundSelector.new(
            combinator: Combinator::None,
            simple_selectors: [ SimpleSelector.new(SelectorType::TagName, "h1") ]
        )
    ])
end

# body > h1
def make_body_gt_h1_selector() : Selector
    return Selector.new("body > h1", [
        CompoundSelector.new(
            combinator: Combinator::None,
            simple_selectors: [ SimpleSelector.new(SelectorType::TagName, "body") ]
        ),
        CompoundSelector.new(
            combinator: Combinator::ImmediateChild,
            simple_selectors: [ SimpleSelector.new(SelectorType::TagName, "h1") ]
        )
    ])
end

def make_div_id_whf_selector() : Selector
    return Selector.new("div#whf", [
        CompoundSelector.new(
            combinator: Combinator::None,
            simple_selectors: [
                SimpleSelector.new(SelectorType::TagName, "div"),
                SimpleSelector.new(SelectorType::Id, "whf"),
            ]
        )
    ])
end

def test_selector(selector : Selector, elements : Array(Element))
    puts "#{selector.text} matches"
    elements.each do |el|
        puts "   <#{el.node_name()}>: #{selector.matches(el)}"
    end
end

document = Document.new()

html = Element.new("html")
document.append_child(html)

head = Element.new("head")
html.append_child(head)

title = Element.new("title")
head.append_child(title)
title.append_child(Text.new("Well hello friends!"))

body = Element.new("body")
html.append_child(body)

h1 = Element.new("h1")
body.append_child(h1)
h1.append_child(Text.new("Welcome :^)"))

div1 = Element.new("div")
div1.set_attribute(name: "id", value: "whf")
body.append_child(div1)

div2 = Element.new("div")
div2.set_attribute(name: "id", value: "sdf")
div2.set_attribute(name: "class", value: "red")
body.append_child(div2)

dump_tree(html)

puts

elements = [body, h1, div1, div2]

test_selector(CSSParser.parse("div#whf"), elements)
test_selector(make_h1_selector(), elements)
test_selector(make_body_gt_h1_selector(), elements)
test_selector(make_div_id_whf_selector(), elements)

puts "--"

test_selector(CSSParser.parse("html body #whf"), elements)
test_selector(CSSParser.parse("html body h1+#whf"), elements)
test_selector(CSSParser.parse("html body h1~#whf"), elements)
test_selector(CSSParser.parse("html body h1+#sdf"), elements)
test_selector(CSSParser.parse("html body h1~#sdf"), elements)
test_selector(CSSParser.parse("html body *"), elements)
test_selector(CSSParser.parse(".red"), elements)

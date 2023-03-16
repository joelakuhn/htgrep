require "xml"
require "./css-parser.cr"

def collect(node : XML::Node, collection = [] of XML::Node)
    if node.name == "p"
        collection.push(node)
    end
    node.children.each do |child|
        collect(child, collection)
    end
    return collection
end

document = XML.parse_html(File.open("test-files/housing.html").gets_to_end)

def collect_nodes(node : XML::Node, collection = [] of XML::Node)
    collection.push(node)
    node.children.each do |child|
        collect_nodes(child, collection)
    end
    return collection
end

h1_sel = CSSParser.parse("article a")
collect_nodes(document).each do |node|
    if h1_sel.matches(node)
        puts node.to_s
    end
end

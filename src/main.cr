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

def collect_matches(matcher : Matcher, node : XML::Node, collection = [] of XML::Node)
    # if matcher.matches(node)
    #     collection.push(node)
    # end
    node.children.each do |child|
        collect_matches(matcher, child, collection)
    end
    return collection
end

matcher = Matcher.new(CSSParser.parse("article a"))
# collect_matches(matcher, document).each do |node|
#     puts node.to_s
# end

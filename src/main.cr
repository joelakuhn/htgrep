require "xml"

def collect(node : XML::Node, collection = [] of XML::Node)
    if node.name == "p"
        collection.push(node)
    end
    node.children.each do |child|
        collect(child, collection)
    end
    return collection
end

document = XML.parse_html("
<!DOCTYPE html>
<html>
<body>
    <h1>Heading</h1>
    <article class=\"main\">
        <p>This is the main content.</p>
    </article>
</body>
</html>
")

puts collect(document)

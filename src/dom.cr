class Node
    property parent : Node? = nil

    def node_name(); "Node"; end
end

class Text < Node
    property data : String

    def initialize(@data); end

    def node_name; "Text"; end
end

class ParentNode < Node
    property children = [] of Node

    def node_name; "ParentNode"; end

    def append_child(child : Node)
        @children.push(child)
        child.parent = self
    end
end

class Document < ParentNode
    def node_name; "Document"; end
end

class Element < ParentNode
    property tag_name : String
    property attributes = Hash(String, String).new

    def initialize(@tag_name); end

    def node_name; @tag_name; end

    def set_attribute(name : String, value : String) : Nil
        @attributes[name] = value
    end

    def get_attribute(name : String) : String?
        @attributes[name]?
    end

    def has_class(class_name : String) : Bool
        if !@attributes.has_key?("class")
            return false
        end
        classes = @attributes["class"].split(/\s+/).map(&.downcase)
        return classes.includes?(class_name.downcase)
    end
end

def dump_tree(node : Node, indent : UInt32 = 0)
    indent.times{print " "}

    case node
    when Text
        puts node.data
    when Element
        print "<", node.node_name()
        node.attributes.each do |k, v|
            print " #{k}=\"#{v}\""
        end
        puts ">"
    else
        puts "<#{node.node_name}>"
    end

    if node.is_a?(ParentNode)
        node.children.each do |child|
            dump_tree(child, indent + 2)
        end
    end
end

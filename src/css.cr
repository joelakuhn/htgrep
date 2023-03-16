require "xml"

enum SelectorType
    Universal
    TagName
    Class
    Id
    Attribute
end

class SimpleSelector
    property type : SelectorType
    property value : String?

    def initialize(@type, @value = nil); end

    def has_class(node : XML::Node, value : String)
        class_attr = node["class"]?
        if class_attr.nil?
            return false
        end
        classes = class_attr.split(/\s+/).map(&.downcase)
        return classes.includes?(value.downcase)
    end

    def matches(node : XML::Node) : Bool
        return case @type
        when SelectorType::Universal then true;
        when SelectorType::TagName then node.name == @value
        when SelectorType::Class then has_class(node, @value.as(String))
        when SelectorType::Id then !node["id"].nil? && node["id"]? == @value
        else false
        end
    end

    def to_s
        return "#{@type.to_s} #{value}"
    end
end

enum Combinator
    None
    Child
    ImmediateChild
    Sibling
    ImmediateSibling
end

class CompoundSelector
    property combinator : Combinator
    property simple_selectors : Array(SimpleSelector)

    def initialize(@combinator, @simple_selectors); end

    def matches(node : XML::Node) : Bool
        @simple_selectors.each do |simple_selector|
            if !simple_selector.matches(node)
                return false
            end
        end
        return true
    end

    def to_s
        return "||#{combinator.to_s}::#{simple_selectors.map(&.to_s).join(",")}"
    end
end

class Selector
    property text : String
    property compound_selectors : Array(CompoundSelector)

    def initialize(@text, @compound_selectors); end

    def matches(node : XML::Node, i = @compound_selectors.size - 1) : Bool

        selector = @compound_selectors[i]
        if !selector.matches(node)
            return false
        end

        if selector.combinator == Combinator::None
            return true

        elsif selector.combinator == Combinator::ImmediateChild
            if node.parent.nil?
                return false
            else
                return matches(node.parent.as(XML::Node), i - 1)
            end

        elsif selector.combinator == Combinator::Child
            current = node
            until current.parent.nil?
                current = current.parent.as(XML::Node)
                if matches(current, i - 1)
                    return true
                end
            end
            return false

        elsif selector.combinator == Combinator::ImmediateSibling
            if node.previous.nil?
                return false
            end
            return matches(node.previous.as(XML::Node), i - 1)

        elsif selector.combinator == Combinator::Sibling
            current = node.previous
            until current.nil?
                if matches(current.as(XML::Node), i - 1)
                    return true
                end
                current = current.previous
            end
        end
        return false
    end

    def to_s
        return compound_selectors.map(&.to_s).join("|")
    end
end

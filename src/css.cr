require "./dom.cr"

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

    def matches(element : Element) : Bool
        return case @type
        when SelectorType::Universal then true;
        when SelectorType::TagName then element.tag_name == @value
        when SelectorType::Class then element.has_class(@value.as(String))
        when SelectorType::Id then element.get_attribute("id") == @value
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

    def matches(element : Element) : Bool
        @simple_selectors.each do |simple_selector|
            unless simple_selector.matches(element)
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

    def matches(element : Element, i = @compound_selectors.size - 1) : Bool

        selector = @compound_selectors[i]
        if !selector.matches(element)
            return false
        end

        if selector.combinator == Combinator::None
            return true

        elsif selector.combinator == Combinator::ImmediateChild
            if element.parent.nil? || !element.parent.is_a?(Element)
                return false
            else
                return matches(element.parent.as(Element), i - 1)
            end
        elsif selector.combinator == Combinator::Child
            current = element
            while current.parent && current.parent.is_a?(Element)
                current = current.parent.as(Element)
                if matches(current, i - 1)
                    return true
                end
            end
            return false
        elsif selector.combinator == Combinator::ImmediateSibling || selector.combinator == Combinator::Sibling
            if element.parent && element.parent.is_a?(Element)
                children = element.parent.as(Element).children
                child_index = children.index(element)
                sibling_index = child_index.nil? ? -1 : child_index - 1
                until sibling_index < 0
                    if children[sibling_index].is_a?(Element)
                        if matches(children[sibling_index].as(Element), i - 1)
                            return true
                        elsif selector.combinator == Combinator::ImmediateSibling
                            return false
                        else
                            sibling_index -= 1
                        end
                    end
                end
            end
        end
        return false
    end

    def to_s
        return compound_selectors.map(&.to_s).join("|")
    end
end

require "./css.cr"

class CSSParser
    def self.parse(str : String)
        complex = str.split(/( *\> *| *\~ *| *\+ *| +)/)
        complex.unshift("");

        compound_selectors = complex.in_groups_of(2).map do |pair|
            comb_str, sel_str = pair
            combinator = CSSParser.parse_combinator(comb_str.as(String))
            simples = CSSParser.parse_simple(sel_str.as(String))
            CompoundSelector.new(combinator, simples)
        end

        return Selector.new(str, compound_selectors)
    end

    def self.parse_simple(str : String) : Array(SimpleSelector)
        pieces = str.split(/(\.\w+|\w+|\[\w+(="\w+")?\]|#\w+)|\*/, remove_empty: true)
        pieces.map do |simple|
            case simple.chars[0]
            when '.'
                SimpleSelector.new(SelectorType::Class, simple[1, simple.size - 1].downcase)
            when '#'
                SimpleSelector.new(SelectorType::Id, simple[1, simple.size - 1])
            when '*'
                SimpleSelector.new(SelectorType::Universal, simple)
            when '['
                SimpleSelector.new(SelectorType::Attribute, simple[1, simple.size - 2])
            else
                SimpleSelector.new(SelectorType::TagName, simple)
            end
        end
    end

    def self.parse_combinator(str : String) : Combinator
        if str == ""
            return Combinator::None
        end
        return case str.strip
        when ">" then Combinator::ImmediateChild
        when "" then Combinator::Child
        when "+" then Combinator::ImmediateSibling
        when "~" then Combinator::Sibling
        else Combinator::None
        end
    end
end

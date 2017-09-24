class Boleite::Text
  class Formatter
    @rules = [] of FormatRule

    def add(rule, color) : self
      @rules << FormatRule.new rule, color
      self
    end

    def format(text, default) : Array(Colorf)
      colors = Array.new text.size, default
      @rules.each do |rule|
        rule.apply_rule text, colors
      end
      colors
    end
  end
end
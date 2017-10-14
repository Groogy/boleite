class Boleite::Text
  struct FormatRule
    @rule : Regex | Range(Int32, Int32) | String
    @color : Colorf

    def initialize(@rule, @color)
    end

    def apply_rule(text, colors)
      case @rule
      when Regex
        apply_regex_rule @rule.as(Regex), text, colors
      when Range(UInt32, UInt32)
        apply_range_rule text, colors
      when String
        apply_keyword_rule text, colors
      end
    end

    def apply_regex_rule(regex, text, colors) 
      pos = 0
      while match = regex.match text, pos
        match.group_size.times do |i|
          start, stop = match.begin(i), match.end(i)
          if start && stop
            (start...stop).each do |p|
              colors[p] = @color
            end
            pos = stop if stop > pos
          else
            pos = text.size
          end
        end
        pos = text.size if match.group_size <= 0
      end
    end

    def apply_range_rule(text, colors)
      range = @rule.as(Range(Int32, Int32))
      range.each do |i|
        colors[i] = @color
      end
    end

    def apply_keyword_rule(text, colors)
      keyword = @rule.as(String)
      apply_regex_rule(/(#{keyword})/, text, colors)
    end
  end
end
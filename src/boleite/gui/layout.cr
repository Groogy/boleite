class Boleite::GUI
  class Layout < Container
    enum Style
      Vertical
      Horizontal
    end

    @padding = Vector2f.new(1.0, 1.0)
    @handling_state_change = false

    getter padding, style
    setter_state padding, style

    def initialize(@style : Style)
      super()
    end

    requires style == :vertical || style == :horizontal
    def initialize(style : Symbol)
      @style = case style
      when :vertical then Style::Vertical
      when :horizontal then Style::Horizontal
      else Style::Vertical
      end
      super()
    end

    protected def on_state_change
      return if @handling_state_change
      @handling_state_change = true
      arrange_child_widgets
      @handling_state_change = false
      super
    end

    protected def arrange_child_widgets
      pos = @padding
      each_widget do |child|
        child.position = pos
        case @style
        when Style::Vertical then pos.y += child.size.y + @padding.y
        when Style::Horizontal then pos.x += child.size.x + @padding.x
        end
      end
    end
  end
end
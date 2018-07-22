class Boleite::GUI
  class WindowHeaderDrag
    @dragging = false
    @pos = Vector2f.zero
    @last = Vector2f.zero

    def initialize(@widget : Window)
    end

    def interested?(event : InputEvent) : Bool
      if event.is_a? MousePosEvent
        @last = @pos
        @pos = event.pos
      elsif event.is_a? MouseButtonEvent
        @dragging = event.button == Mouse::Left
        @dragging = @dragging && event.action != InputAction::Release
        @dragging = @dragging && @widget.header_allocation.contains? @pos
      else
        @dragging = false
      end
      @dragging
    end

    def translate(event : InputEvent)
      event.claim
      {@pos - @last}
    end
  end

  class WindowClaimLeftovers
    def initialize(@widget : Window)
    end

    def interested?(event : InputEvent) : Bool
      @widget.has_mouse_focus?
    end

    def translate(event : InputEvent)
      event.claim
      Tuple.new
    end
  end
end
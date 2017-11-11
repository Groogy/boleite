class Boleite::GUI
  class WindowHeaderDrag
    @dragging = false
    @pos = Vector2f.zero
    @last = Vector2f.zero

    def initialize(@widget : Widget)
    end

    def interested?(event : InputEvent) : Bool
      if event.is_a? MousePosEvent
        @last = @pos
        @pos = event.pos
      elsif event.is_a? MouseButtonEvent
        @dragging = event.button == Mouse::Left && event.action != InputAction::Release
      end
      @dragging
    end

    def translate(event : InputEvent)
      {@pos - @last}
    end
  end
end
class Boleite::GUI
  class ButtonClick
    @pos = Vector2f.zero
    @clicked_inside = false

    def initialize(@widget : Button)
    end

    def interested?(event : InputEvent) : Bool
      if event.is_a? MousePosEvent
        @pos = event.pos
      elsif event.is_a? MouseButtonEvent
        if @widget.absolute_allocation.contains? @pos
          if event.button == Mouse::Left && event.action == InputAction::Press
            @clicked_inside = true
          end
        else
          @clicked_inside = false
        end

        if @clicked_inside
          event.claim
        end
        
        return @clicked_inside && event.action == InputAction::Release
      end
      return false
    end

    def translate(event : InputEvent)
      event.claim
      Tuple.new
    end
  end
end
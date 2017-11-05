class Boleite::GUI
  class WidgetMouseEnter
    def initialize(@widget : Widget)
    end

    def interested?(event : InputEvent) : Bool
      if @widget.has_mouse_focus? == false && event.is_a? MousePosEvent
        allocation = @widget.absolute_allocation
        allocation.contains? event.pos
      else
        false
      end
    end

    def translate(event : InputEvent)
      Tuple.new
    end
  end

  class WidgetMouseLeave
    def initialize(@widget : Widget)
    end

    def interested?(event : InputEvent) : Bool
      if @widget.has_mouse_focus? && event.is_a? MousePosEvent
        allocation = @widget.absolute_allocation
        !allocation.contains? event.pos
      else
        false
      end
    end

    def translate(event : InputEvent)
      Tuple.new
    end
  end

  class WidgetMouseOver
    def initialize(@widget : Widget)
    end

    def interested?(event : InputEvent) : Bool
      if @widget.has_mouse_focus? && event.is_a? MousePosEvent
        true
      else
        false
      end
    end

    def translate(event : InputEvent)
      event = event.as(MousePosEvent)
      pos = @widget.absolute_position
      {event.x - pos.x, event.y - pos.y}
    end
  end

  class WidgetMouseClick
    @last_pos = Vector2f.zero
    @state = false

    def initialize(@widget : Widget, @button : Mouse)
    end

    def interested?(event : InputEvent) : Bool
      if @widget.has_mouse_focus?
        if event.is_a? MousePosEvent
          @last_pos = event.pos
        elsif event.is_a? MouseButtonEvent
          return handle_button_state(event)
        end
      else
        @state = false
      end
      return false
    end

    def translate(event : InputEvent)
      pos = @widget.absolute_position
      {@last_pos.x - pos.x, @last_pos.y - pos.y}
    end

    def handle_button_state(event : MouseButtonEvent) : Bool
      old_state = @state
      if event.button == @button
        @state = event.action != InputAction::Release
      end
      old_state == true && old_state != @state
    end
  end
end
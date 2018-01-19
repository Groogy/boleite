class Boleite::GUI
  class ContainerInputPass
    @pos = Vector2f.zero

    def initialize(@widget : Container)
    end

    def interested?(event : InputEvent) : Bool
      if event.is_a? MousePosEvent
        @pos = event.pos
      end
      case event
      when MousePosEvent, MouseButtonEvent, MouseScrollEvent
        return @widget.absolute_allocation.contains? @pos
      else
        return true
      end
    end

    def translate(event : InputEvent)
      {event}
    end
  end
end
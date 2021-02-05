class Boleite::GUI
  class RootMouseOver 
    @pos = Vector2f.zero
    @clicked_inside = false
    
    def initialize(@gui : GUI)
    end

    def interested?(event : InputEvent) : Bool
      if event.is_a? MousePosEvent
        @pos = event.pos
      elsif event.is_a? MouseButtonEvent
        @gui.each_root do |root|
          if root.absolute_allocation.contains? @pos
            return event.action == InputAction::Release
          end
        end
      end
      return false
    end

    def translate(event : InputEvent)
      {@pos}
    end
  end
end
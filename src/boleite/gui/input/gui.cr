class Boleite::GUI
  class RootMouseOver
    def initialize(@gui : GUI)
    end

    def interested?(event : InputEvent) : Bool
      if event.is_a? MousePosEvent
        @gui.each_root do |root|
          return true if root.allocation.contains? event.pos
        end
      end
      false
    end

    def translate(event : InputEvent)
      event = event.as(MousePosEvent)
      {event.pos}
    end
  end
end
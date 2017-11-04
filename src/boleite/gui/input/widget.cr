class Boleite::GUI
  class WidgetMouseEnter
    def initialize(@widget : Widget)
    end

    def interested?(event : Boleite::InputEvent) : Bool
      false
    end

    def translate(event : Boleite::InputEvent)
      Tuple.new
    end
  end
end
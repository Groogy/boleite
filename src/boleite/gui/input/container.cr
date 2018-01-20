class Boleite::GUI
  class ContainerInputPass
    def initialize(@widget : Container)
    end

    def interested?(event : InputEvent) : Bool
      true
    end

    def translate(event : InputEvent)
      {event}
    end
  end
end
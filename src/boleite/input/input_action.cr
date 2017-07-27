module Boleite
  class ClosedAction
    def interested?(event : InputEvent) : Bool
      event.class == ClosedEvent
    end

    def translate(event : InputEvent)
      Tuple.new
    end
  end

  class PassThroughAction
    def interested?(event : InputEvent) : Bool
      true
    end

    def translate(event : InputEvent)
      {event}
    end
  end
end
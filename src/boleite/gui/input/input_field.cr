class Boleite::GUI
  class InputField < Widget
  end

  class InputFieldEnterText
    def initialize(@widget : InputField)
    end

    def interested?(event : InputEvent) : Bool
      @widget.input_focus? && event.is_a? CharEvent
    end

    def translate(event : InputEvent)
      event = event.as(CharEvent)
      event.claim
      {event.char.chr}
    end
  end
  
  class InputFieldKeyPress
    def initialize(@widget : InputField, @key : Key)
    end

    def interested?(event : InputEvent) : Bool
      if @widget.input_focus? && event.is_a? KeyEvent
        event = event.as(KeyEvent)
        event.key == @key && event.action != InputAction::Release
      else
        false
      end
    end

    def translate(event : InputEvent)
      event.claim
      Tuple.new
    end
  end

  class InputFieldCatchAllKey
    def initialize(@widget : InputField)
    end

    def interested?(event : InputEvent) : Bool
      @widget.input_focus? && event.is_a? KeyEvent
    end

    def translate(event : InputEvent)
      event = event.as(KeyEvent)
      event.claim
      {event.key, event.action}
    end
  end

  class InputFieldLoseFocus
    def initialize(@widget : InputField)
    end

    def interested?(event : InputEvent) : Bool
      !@widget.has_mouse_focus? && event.is_a? MouseButtonEvent
    end

    def translate(event : InputEvent)
      Tuple.new
    end
  end
end
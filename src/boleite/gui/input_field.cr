class Boleite::GUI
  abstract class Widget
  end

  class InputField < Widget
    @label = Label.new
    @input_focus = false

    getter label

    Cute.signal click(pos : Vector2f)
    Cute.signal text_entered(char : Char)
    Cute.signal key_pressed(key : Key, action : InputAction)
    Cute.signal lose_input_focus

    def initialize
      super
      
      @label.orientation = Label::Orientation::Left
      @label.parent = self

      state_change.on &->update_label_size
      text_entered.on &->(char : Char) { self.value = self.value + char }
      key_pressed.on &->self.handle_special_keys(Key, InputAction)
      click.on &->(pos : Vector2f) { self.input_focus = true }
      lose_input_focus.on &-> { self.input_focus = false }

      clicker = WidgetBasicClick.new self, Mouse::Left
      @input.register_instance clicker, click
      @input.register_instance InputFieldEnterText.new(self), text_entered
      @input.register_instance InputFieldKeyPress.new(self), key_pressed
      @input.register_persistent_instance InputFieldLoseFocus.new(self), lose_input_focus
    end

    def initialize(text, size = Vector2f.zero)
      self.initialize
      self.value = text
      self.size = size
    end

    def value=(text)
      @label.text = text
      state_change.emit
    end

    def value
      @label.text
    end

    def input_focus?
      @input_focus
    end

    def input_focus=(@input_focus)
    end

    protected def update_label_size
      @label.size = self.size
    end

    protected def handle_special_keys(key : Key, action : InputAction)
      return if action == InputAction::Release
      case key
      when Key::Backspace
        self.value = self.value.rchop
      end
    end
  end
end

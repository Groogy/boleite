class Boleite::GUI
  abstract class Widget
  end

  class InputField < Widget
    @label = Label.new
    @input_focus = false

    getter label
    getter? input_focus

    Cute.signal click(pos : Vector2f)
    Cute.signal text_entered(char : Char)
    Cute.signal lose_input_focus

    def initialize
      super
      
      @label.orientation = Label::Orientation::Left
      @label.parent = self

      state_change.on &->update_label_size
      text_entered.on &->handle_text_input(Char)
      click.on &->(pos : Vector2f) { self.input_focus = true }
      lose_input_focus.on &-> { self.input_focus = false }

      clicker = WidgetBasicClick.new self, Mouse::Left
      @input.register_instance clicker, click
      @input.register_instance InputFieldEnterText.new(self), text_entered
      @input.register_instance InputFieldKeyPress.new(self, Key::Left), ->move_cursor_back
      @input.register_instance InputFieldKeyPress.new(self, Key::Right), ->move_cursor_forward
      @input.register_instance InputFieldKeyPress.new(self, Key::Backspace), ->handle_backspace
      @input.register_persistent_instance InputFieldLoseFocus.new(self), lose_input_focus
    end

    def initialize(text, size = Vector2f.zero)
      self.initialize
      self.value = text
      self.size = size
    end

    def value=(text)
      @label.text = text
      @label.cursor_position = text.size
      state_change.emit
    end

    def value
      @label.text
    end

    def input_focus=(@input_focus)
      @label.use_cursor = @input_focus
    end

    protected def update_label_size
      @label.size = self.size
    end

    protected def handle_text_input(char : Char)
      pos = @label.cursor_position
      @label.text = @label.text.insert pos, char
      @label.cursor_position += 1
      state_change.emit
    end

    protected def move_cursor_back
      @label.cursor_position -= 1
      state_change.emit
    end

    protected def move_cursor_forward
      @label.cursor_position += 1
      state_change.emit
    end

    protected def handle_backspace
      cursor = @label.cursor_position
      text = @label.text
      if cursor > 0
        self.value = text[0, cursor-1] + text[cursor, text.size]
        @label.cursor_position -= 1 if cursor < text.size
      end
      state_change.emit
    end
  end
end

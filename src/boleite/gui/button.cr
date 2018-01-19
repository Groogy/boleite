class Boleite::GUI
  abstract class Widget
  end

  class Button < Widget
    @label = Label.new

    getter label

    Cute.signal click(pos : Vector2f)

    def initialize
      super
      
      @label.orientation = Label::Orientation::Center
      @label.parent = self

      state_change.on &->update_label_size

      clicker = Boleite::GUI::WidgetBasicClick.new self, Boleite::Mouse::Left
      @input.register_instance clicker, click
    end

    def initialize(text, size = Vector2f.zero)
      self.initialize
      self.label_text = text
      self.size = size
    end

    def label_text=(text)
      @label.text = text
      state_change.emit
    end

    protected def update_label_size
      @label.size = self.size
    end
  end
end
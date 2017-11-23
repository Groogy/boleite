class Boleite::GUI
  abstract class Widget
  end

  class Button < Widget
    DEFAULT_BORDER_SIZE = 1.0

    @border_size = DEFAULT_BORDER_SIZE
    @label = Label.new

    getter label, border_size

    Cute.signal click

    def initialize
      super
      
      @label.orientation = Label::Orientation::Center
      @label.parent = self

      state_change.on &->update_label_size

      @input.register_instance ButtonClick.new(self), click
    end

    def initialize(text, size = Vector2f.zero)
      self.initialize
      self.label_text = text
      self.size = size
    end

    def border_size=(size)
      @border_size = size
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
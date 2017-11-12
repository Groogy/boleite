class Boleite::GUI
  class Window < Container
    DEFAULT_SIZE = Vector2f.new 100.0, 30.0
    DEFAULT_HEADER_SIZE = 20.0
    DEFAULT_BORDER_SIZE = 1.0

    @header_size = DEFAULT_HEADER_SIZE
    @border_size = DEFAULT_BORDER_SIZE
    @header_label = Label.new

    getter header_size, border_size, header_label

    Cute.signal header_drag(pos : Vector2f)

    def initialize
      super
      self.min_size = DEFAULT_SIZE

      @header_label.position = Vector2f.new @border_size, @border_size
      @header_label.parent = self

      state_change.on &->update_header_size
      header_drag.on &->move(Vector2f)
      @input.register_instance WindowHeaderDrag.new(self), header_drag
    end

    def header_size=(size)
      @header_size = size
    end

    def border_size=(size)
      @border_size = size
    end

    def header_allocation
      pos = absolute_position
      FloatRect.new pos.x, pos.y - @header_size + @border_size, size.x, @header_size
    end

    def header_text=(text)
      @header_label.text = text
    end

    def header_character_size=(size)
      @header_label.character_size = size
    end

    protected def update_header_size
      @header_label.size = Vector2f.new size.x, @header_size
    end
  end
end
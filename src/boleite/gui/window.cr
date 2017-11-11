class Boleite::GUI
  class Window < Container
    DEFAULT_SIZE = Vector2f.new 100.0, 30.0
    DEFAULT_HEADER_SIZE = 20.0
    DEFAULT_BORDER_SIZE = 1.0

    @header_size = DEFAULT_HEADER_SIZE
    @border_size = DEFAULT_BORDER_SIZE

    getter header_size
    getter border_size

    Cute.signal header_drag(pos : Vector2f)

    def initialize
      super
      self.min_size = DEFAULT_SIZE

      header_drag.on &->move(Vector2f)
      
      @input.register_instance WindowHeaderDrag.new(self), header_drag
    end

    def header_size=(size)
      @header_size = size
    end

    def border_size=(size)
      @border_size = size
    end
  end
end
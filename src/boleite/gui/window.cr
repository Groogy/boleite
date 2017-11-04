class Boleite::GUI
  class Window < Container
    DEFAULT_SIZE = Vector2f.new 100.0, 30.0
    DEFAULT_HEADER_SIZE = 20.0
    DEFAULT_BORDER_SIZE = 1.0

    @header_size = DEFAULT_HEADER_SIZE
    @border_size = DEFAULT_BORDER_SIZE

    getter header_size
    getter border_size

    def initialize
      self.min_size = DEFAULT_SIZE
    end

    def header_size=(size)
      @header_size = size
    end

    def border_size=(size)
      @border_size = size
    end
  end
end
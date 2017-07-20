module Boleite
  struct VideoMode
    property :resolution
    property :mode

    enum Mode : UInt8
      Windowed
      Fullscreen
      Borderless
    end

    @resolution = Vector2u.zero
    @mode = Mode::Windowed

    def initialize()
    end

    def initialize(width, height, @mode)
      @resolution.x = width
      @resolution.y = height
    end
  end
end
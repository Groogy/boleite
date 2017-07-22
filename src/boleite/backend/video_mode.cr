module Boleite
  struct VideoMode
    property :resolution
    property :mode
    property :refresh_rate

    enum Mode : UInt8
      Windowed
      Fullscreen
      Borderless
    end

    @resolution = Vector2u.zero
    @mode = Mode::Windowed
    @refresh_rate = Int16.zero

    def initialize()
    end

    def initialize(width, height, @mode, @refresh_rate = Int16.zero)
      @resolution.x = width
      @resolution.y = height
    end

    def any_refresh_rate?
      @refresh_rate.zero?
    end
  end
end
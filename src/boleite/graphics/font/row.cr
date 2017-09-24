class Boleite::Font
  class Row
    property width, top, height

    @width = 0u32
    @top = 0u32
    @height = 0u32

    def initialize(@top, @height)
    end
  end
end
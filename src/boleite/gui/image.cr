class Boleite::GUI
  class Image < Widget
    @texture : Texture?

    getter texture
    setter_state texture

    def initialize()
      super
    end

    def initialize(@texture)
      super
      self.size = @texture.size
    end
  end
end
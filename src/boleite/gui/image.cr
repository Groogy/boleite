class Boleite::GUI
  class Image < Widget
    @texture : Texture?

    getter texture
    setter_state texture

    def initialize()
      super
    end

    def initialize(@texture)
      super()
      if texture = @texture
        self.size = texture.size.to_f
      else
        self.size = Vector2f.zero
      end
    end
  end
end
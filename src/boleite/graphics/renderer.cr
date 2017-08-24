abstract class Boleite::Renderer
  def initialize(@gfx : GraphicsContext)
  end

  abstract def clear(color : Colorf) : Void
  abstract def draw(vbo : VertexBufferObject) : Void
  abstract def present : Void
end

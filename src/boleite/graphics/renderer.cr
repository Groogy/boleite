abstract class Boleite::Renderer
  def initialize(@gfx : GraphicsContext, @camera)
  end

  def draw(drawable : Drawable, transform = Matrix44f32.identity)
    drawable.render(self, transform)
  end

  abstract def clear(color : Colorf) : Void
  abstract def draw_vertices(vbo : VertexBufferObject, shader : Shader?, transform : Matrix44f32) : Void
  abstract def present : Void
end

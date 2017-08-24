abstract class Boleite::Renderer
end

class Boleite::ForwardRenderer < Boleite::Renderer
  def initialize(@gfx : GraphicsContext, @default_shader : Shader)
  end

  def clear(color : Colorf)
    @gfx.clear color
  end

  def draw(vbo : VertexBufferObject)
    @default_shader.activate do
      vbo.render
    end
  end

  def present
    @gfx.present
  end
end
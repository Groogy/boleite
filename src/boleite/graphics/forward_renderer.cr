abstract class Boleite::Renderer
end

class Boleite::ForwardRenderer < Boleite::Renderer
  def initialize(@gfx : GraphicsContext, @camera : Camera, @default_shader : Shader)
  end

  def clear(color : Colorf)
    @gfx.clear color
  end

  def draw(vbo : VertexBufferObject)
    apply_shader_settings
    @default_shader.activate do
      vbo.render
    end
  end

  def present
    @gfx.present
  end

  def apply_shader_settings
    @default_shader.world_transform = Matrix44f32.identity
    @default_shader.view_transform = @camera.inverse_transformation
    @default_shader.projection_transform = @camera.projection
  end
end
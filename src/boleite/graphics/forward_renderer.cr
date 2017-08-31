abstract class Boleite::Renderer
end

class Boleite::ForwardRenderer < Boleite::Renderer
  def initialize(@gfx : GraphicsContext, @camera : Camera, @default_shader : Shader)
  end

  def clear(color : Colorf)
    @gfx.clear color
  end

  def draw_vertices(vbo, shader, transform)
    shader = ensure_shader shader
    apply_shader_settings shader, transform
    shader.activate do
      vbo.render
    end
  end

  def present
    @gfx.present
  end
  
  def ensure_shader(shader) : Shader
    if shader
      shader
    else
      @default_shader
    end
  end

  def apply_shader_settings(shader, transform)
    shader.world_transform = transform
    shader.view_transform = @camera.inverse_transformation
    shader.projection_transform = @camera.projection
  end
end
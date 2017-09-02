abstract class Boleite::Renderer
end

class Boleite::ForwardRenderer < Boleite::Renderer
  def initialize(@gfx : GraphicsContext, @camera : Camera, @default_shader : Shader)
  end

  def clear(color : Colorf)
    @gfx.clear color
  end

  def draw(drawcall : DrawCallContext)
    shader = ensure_shader drawcall.shader
    apply_shader_settings shader, drawcall.transformation, drawcall.uniforms
    drawcall.buffers.each { |buffer| drawcall.vertices.attach_buffer(buffer, true) }
    shader.activate do
      drawcall.vertices.render(1)
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
end
abstract class Boleite::Renderer
end

class Boleite::ForwardRenderer < Boleite::Renderer
  def initialize(@gfx : GraphicsContext, @camera : Camera, @default_shader : Shader)
  end

  def clear(color : Colorf) : Void
    @gfx.clear color
    @gfx.clear_depth
  end

  def draw(drawcall : DrawCallContext) : Void
    shader = ensure_shader drawcall.shader
    apply_shader_settings shader, drawcall.transformation, drawcall.uniforms
    drawcall.buffers.each { |buffer| drawcall.vertices.attach_buffer(buffer, true) }
    shader.activate do
      drawcall.vertices.render(1)
    end
  end

  def present : Void
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
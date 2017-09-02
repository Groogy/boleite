struct Boleite::DrawCallContext
  property vertices, transformation, shader
  property uniforms, buffers

  @vertices : VertexBufferObject
  @transformation = Matrix44f32.identity
  @shader = nil
  @uniforms = DrawCallUniforms.new
  @buffers = [] of VertexBuffer

  def initialize(@vertices : VertexBufferObject, @transformation = Matrix44f32.identity)
  end

  def initialize(@vertices : VertexBufferObject, @shader : Shader, @transformation = Matrix44f32.identity)
  end
end

struct Boleite::DrawCallUniforms
  alias Value = Float32 | Vector2f32 | Vector3f32 | Vector4f32 | Matrix33f32 | Matrix44f32 | Texture

  @values = {} of String => Value

  def []=(name, value)
    @values[name] = value
  end

  def apply_to(shader)
    @values.each do |key, value|
      apply_value shader, key, value
    end
  end

  protected def apply_value(shader, key, value)
    shader.set_parameter(key, value)
  end
end

abstract class Boleite::Renderer
  getter gfx

  def initialize(@gfx : GraphicsContext, @camera)
  end

  def draw(drawable : Drawable, transform = Matrix44f32.identity)
    drawable.render(self, transform)
  end

  abstract def clear(color : Colorf) : Void
  abstract def draw(drawcall : DrawCallContext) : Void
  abstract def present : Void

  protected def apply_shader_settings(shader, world, uniforms)
    shader.world_transform = world
    shader.view_transform = @camera.inverse_transformation
    shader.projection_transform = @camera.projection
    uniforms.apply_to shader
  end
end

require "./sprite/vertices.cr"

module Boleite::Transformable
end

class Boleite::Sprite
  include Drawable
  include Transformable

  getter texture, texture_rect, size

  @size : Vector2u
  @vertices = Vertices.new

  def initialize(@texture : Texture)
    @size = @texture.size
    @texture_rect = IntRect.new(0, 0, @size.x.to_i, @size.y.to_i)
    @vertices.update_uv_vertices @size, @texture_rect
  end

  def texture=(@texture)
    @size = @texture.size
    @texture_rect = IntRect.new(0, 0, @size.x.to_i, @size.y.to_i)
    @vertices.update_uv_vertices @size, @texture_rect
  end

  def texture_rect=(rect)
    @texture_rect = rect
    @vertices.update_uv_vertices @texture.size, @texture_rect
  end

  def size=(size)
    @size = size
    @vertices.update_uv_vertices @texture.size, @texture_rect
  end

  protected def internal_render(renderer, transform)
    vertices = @vertices.get_vertices(renderer.gfx)
    shader = @vertices.get_shader(renderer.gfx)
    uv = @vertices.get_uv(renderer.gfx)
    scale_transform = Matrix.scale Matrix44f32.identity, Vector4f32.new(@size.x.to_f32, @size.y.to_f32, 1f32, 1f32)
    transform = Matrix.mul transform, self.transformation
    transform = Matrix.mul scale_transform, transform
    drawcall = DrawCallContext.new vertices, shader, transform
    drawcall.uniforms["colorTexture"] = texture
    drawcall.buffers << uv
    renderer.draw drawcall
  end
end
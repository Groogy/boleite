require "./shape/vertices.cr"

module Boleite::Transformable
end

class Boleite::Shape
  include Drawable
  include Transformable

  @vertices = Vertices.new
  @color = Color.white
  @custom_shader : Shader?

  property color

  def initialize()
  end

  def add_vertex(x, y)
    add_vertex Vector2f32.new(x.to_f32, y.to_f32)
  end

  def add_vertex(pos)
    @vertices.add pos
  end

  def []=(index, pos) : Vector2f32
    @vertices.set index, pos
  end

  def [](index) : Vector2f32
    @vertices.get index
  end

  def num_vertices
    @vertices.size
  end

  def clear_vertices
    @vertices.clear
  end

  protected def internal_render(renderer, transform)
    vertices = @vertices.get_vertices(renderer.gfx)
    unless shader = @custom_shader
      shader = @vertices.get_shader(renderer.gfx)
    end
    transform = Matrix.mul transform, self.transformation
    drawcall = DrawCallContext.new vertices, shader, transform
    drawcall.uniforms["color"] = @color
    renderer.draw drawcall
  end
end
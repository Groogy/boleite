require "./shape/vertices.cr"

module Boleite::Transformable
end

class Boleite::Shape
  include Drawable
  include Transformable

  getter size

  @vertices = Vertices.new
  @color = Color.white

  property color

  def initialize()
  end

  def add_vertex(x, y)
    add_vertex Vector2f32.new(x.to_f32, y.to_f32)
  end

  def add_vertex(pos)
    @vertices.add pos
  end

  def clear_vertices
    @vertices.clear
  end

  protected def internal_render(renderer, transform)
    vertices = @vertices.get_vertices(renderer.gfx)
    shader = @vertices.get_shader(renderer.gfx)
    transform = Matrix.mul transform, self.transformation
    drawcall = DrawCallContext.new vertices, shader, Matrix44f32.identity
    drawcall.uniforms["color"] = @color
    renderer.draw drawcall
  end
end
module Boleite::Drawable
end

module Boleite::Transformable
end

class Boleite::LineShape
  include Drawable
  include Transformable

  @shape = Shape.new Primitive::LinesStrip

  delegate :color, :color=, to: @shape

  def initialize
  end

  def add(x, y)
    @shape.add_vertex x, y
  end

  def add(pos)
    add pos.x, pos.y
  end

  def num_points
    @shape.num_vertices
  end

  def num_lines
    1 + (@shape.num_vertices - 1) / 2
  end

  private def internal_render(renderer, transform)
    transform = Matrix.mul transform, self.transformation
    renderer.draw @shape, transform
  end
end
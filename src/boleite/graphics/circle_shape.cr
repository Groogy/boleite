module Boleite::Drawable
end

module Boleite::Transformable
end

class Boleite::CircleShape
  include Drawable
  include Transformable

  @rebuild = true
  @shape = Shape.new Primitive::TriangleFan

  getter radius
  getter quality = 32

  delegate :color, :color=, to: @shape

  def initialize(@radius = 1.0)
  end

  def radius=(@radius)
    @rebuild = true
  end

  def quality=(@quality)
    @rebuild = true
  end

  private def internal_render(renderer, transform)
    build_circle if @rebuild
    transform = Matrix.mul transform, self.transformation
    renderer.draw @shape, transform
  end

  def build_circle
    @shape.clear_vertices
    @shape.add_vertex Boleite::Vector2f32.zero
    step = -(Math::PI * 2.0) / @quality
    (0..@quality).each do |index|
      point1 = Boleite::Vector2f.new @radius * Math.cos(index * step), @radius * Math.sin(index * step)
      point2 = Boleite::Vector2f.new @radius * Math.cos((index + 1) * step), @radius * Math.sin((index + 1) * step)

      @shape.add_vertex point1.to_f32
      @shape.add_vertex point2.to_f32
    end
    @rebuild = false
  end
end
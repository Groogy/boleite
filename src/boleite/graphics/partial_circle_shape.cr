module Boleite::Drawable
end

module Boleite::Transformable
end

class Boleite::PartialCircleShape
  include Drawable
  include Transformable

  @rebuild = true
  @shape = Shape.new Primitive::TriangleFan

  getter radius, degrees
  getter quality = 32

  delegate :color, :color=, to: @shape

  def initialize(@radius = 1.0, @degrees = 360.0)
  end

  def radius=(@radius)
    @rebuild = true
  end

  def degrees=(@degrees)
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
    step = -@degrees * (Math::PI / 180.0) / @quality
    (0..@quality).each do |index|
      point1 = Boleite::Vector2f.new @radius * Math.cos(index * step), @radius * Math.sin(index * step)
      point2 = Boleite::Vector2f.new @radius * Math.cos((index + 1) * step), @radius * Math.sin((index + 1) * step)

      if @degrees > 0 # Positive direction
        @shape.add_vertex point1.to_f32
        @shape.add_vertex point2.to_f32
      else
        @shape.add_vertex point2.to_f32
        @shape.add_vertex point1.to_f32
      end
    end
    @rebuild = false
  end
end
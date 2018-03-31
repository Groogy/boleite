class Boleite::Camera2D < Boleite::Camera
  property width, height, near, far
  
  def initialize(width : Float32, height : Float32, near : Float32, far : Float32)
    super(Matrix.calculate_ortho_projection(0.0f32, width, 0.0f32, height, near, far))
    @width = width
    @height = height
    @near = near
    @far = far
  end

  def update_transformation
    @transform = Matrix44f32.identity
  end
end
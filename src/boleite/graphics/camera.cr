abstract class Boleite::Camera
  def initialize(@projection : Matrix44f32)
    @transformation = Matrix44f32.identity
  end

  def transformation
    @transformation
  end

  def inverse_transformation
    Matrix.inverse(@transformation)
  end

  def projection
    @projection
  end
end
abstract class Boleite::Camera
  def initialize(@projection : Matrix44f32)
    @transform = Matrix44f32.identity
  end

  def transformation
    @transform
  end

  def inverse_transformation
    Matrix.inverse self.transformation
  end

  def projection
    @projection
  end

  def inverse_projection
    Matrix.inverse self.projection
  end
end
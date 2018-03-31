abstract class Boleite::Camera
  @update_transform = true

  def initialize(@projection : Matrix44f32)
    @transform = Matrix44f32.identity
  end

  def transformation
    if @update_transform
      update_transformation
      @update_transform = false
    end
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

  abstract def update_transformation
end
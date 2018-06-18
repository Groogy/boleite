class Boleite::Camera2D < Boleite::Camera
  @pos = Vector2f.zero
  @scale = 1.0
  
  property width, height, near, far
  getter scale
  
  def initialize(width : Float32, height : Float32, near : Float32, far : Float32)
    super(Matrix.calculate_ortho_projection(0.0f32, width, 0.0f32, height, near, far))
    @width = width
    @height = height
    @near = near
    @far = far
  end

  def position
    @pos
  end

  def position=(pos)
    @update_transform = @update_transform || @pos != pos
    @pos = pos
  end

  def scale=(scale)
    @update_transform = @update_transform || @scale != scale
    @scale = scale
  end

  def move(offset)
    self.position = position + offset
  end

  def move(x, y)
    self.position = position + Vector2f.new(x, y)
  end

  def update_transformation
    p = @pos.to_f32
    s = @scale.to_f32
    @transform = Matrix44f32.identity
    @transform = Matrix.translate @transform, Vector3f32.new(p.x, p.y, 0f32)
    @transform = Matrix.scale @transform, Vector4f32.new(s, s, s, 1f32)
  end
end
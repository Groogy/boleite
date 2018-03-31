class Boleite::Camera3D < Boleite::Camera  
  @pos = Vector3f.zero
  @rot = Vector3f.zero

  getter width, height, near, far
  
  def initialize(@fov : Float32, @width : Float32, @height : Float32, @near : Float32, @far : Float32)
    aspect = width / height
    fov = @fov * (Math::PI / 180)
    super(Matrix.calculate_fov_projection(fov, aspect, @near, @far, true))
  end

  def position
    @pos
  end

  def position=(pos)
    @pos = pos
    @update_transform = true
  end

  def rotation
    @rot
  end

  def rotation=(rot)
    @rot = rot
    @update_transform = true
  end

  def move(offset)
    self.position = position + offset
  end

  def move(x, y, z)
    self.position = position + Vector3f.new(x, y, z)
  end

  def rotate(vec)
    self.rotation = rotation + vec
  end

  def rotate(x, y, z)
    self.rotation = rotation + Vector3f.new(x, y, z)
  end

  def update_transformation
    @transform = Matrix44f32.identity
    @transform = Matrix.translate @transform, @pos.to_f32
    x = Matrix.rotate_around_x Matrix44f32.identity, @rot.x.to_f32
    y = Matrix.rotate_around_y Matrix44f32.identity, @rot.y.to_f32
    z = Matrix.rotate_around_z Matrix44f32.identity, @rot.z.to_f32
    rot = Matrix.mul x, Matrix.mul y, z
    @transform = Matrix.mul rot, @transform
  end
end

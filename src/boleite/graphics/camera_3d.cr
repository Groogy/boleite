class Boleite::Camera3D < Boleite::Camera  
  @update_transform = true
  @pos = Vector3f.zero
  @rot = Vector3f.zero
  
  def initialize(@fov : Float32, @width : Float32, @height : Float32, @near : Float32, @far : Float32)
    aspect = width / height
    super(Matrix.calculate_fov_projection(@fov, aspect, @near, @far, true))
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

  def transformation
    if @update_transform
      update_transformation
      @update_transform = false
    end
    @transform
  end

  def update_transformation
    @transform = Matrix44f32.identity
    @transform = Matrix.translate @transform, @pos.to_f32
    @transform = Matrix.rotate_around_x @transform, @rot.x.to_f32
    @transform = Matrix.rotate_around_y @transform, @rot.y.to_f32
    @transform = Matrix.rotate_around_z @transform, @rot.z.to_f32
  end
end

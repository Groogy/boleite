class Boleite::Camera3D < Boleite::Camera  
  @update_transform = true
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

  def viewport # Tmp, should improve this so viewport can be set
    FloatRect.new 0.0, 0.0, @width.to_f, @height.to_f
  end

  def convert_to_viewport(pos)
    viewport = self.viewport
    pos.x -= viewport.left
    pos.y = @height - pos.y - 1
    pos.y -= viewport.top
    pos.x = (2 * pos.x) / viewport.width - 1
    pos.y = (2 * pos.y) / viewport.height - 1
    pos.z = 2 * pos.z - 1
    pos
  end

  def unproject(pos)
    pos = convert_to_viewport pos
    mat = Matrix.mul projection, transformation
    mat = Matrix.inverse mat
    Vector.project pos, mat
  end

  def screen_point_to_ray(pos)
    near = unproject Vector3f32.new pos.x.to_f32, pos.y.to_f32, 0f32
    far = unproject Vector3f32.new pos.x.to_f32, pos.y.to_f32, 1f32
    Ray.new position.to_f32, Vector.normalize far - near
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
    x = Matrix.rotate_around_x Matrix44f32.identity, @rot.x.to_f32
    y = Matrix.rotate_around_y Matrix44f32.identity, @rot.y.to_f32
    z = Matrix.rotate_around_z Matrix44f32.identity, @rot.z.to_f32
    rot = Matrix.mul x, Matrix.mul y, z
    @transform = Matrix.mul rot, @transform
  end
end

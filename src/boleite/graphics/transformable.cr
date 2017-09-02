module Boleite::Transformable
  @update_transform = true
  @transform = Matrix44f32.identity
  @pos = Vector2f.zero
  @origo = Vector2f.zero
  @scale = Vector2f.one
  @rot = 0.0

  def position
    @pos
  end

  def position=(pos)
    @pos = pos
    @update_transform = true
  end

  def origo
    @origo
  end

  def origo=(origo)
    @origo = origo
    @update_transform = true
  end

  def scale
    @scale
  end

  def scale=(scale)
    @scale = scale
    @update_transform = true
  end

  def rotation
    @rot
  end

  def rotation=(rot)
    @rot = rot
    @update_transform = true
  end

  def transformation
    if @update_transform
      update_transformation
      @update_transform = false
    end
    @transform
  end

  def update_transformation
    angle = @rot * Math::PI / 180.0
    p angle
    cosine = Math.cos angle
    sine = Math.sin angle
    sc = Vector2f.new @scale.x * cosine, @scale.y * cosine
    ss = Vector2f.new @scale.x * sine, @scale.y * sine
    pos = Vector2f.new -@origo.x * sc.x - @origo.y * ss.y, @origo.x * ss.x - @origo.y * sc.y
    pos += @pos
    @transform = Matrix44f32.new(*{
      sc.x.to_f32,   -ss.x.to_f32,    0f32,   0f32,
      ss.y.to_f32,    sc.y.to_f32,    0f32,   0f32,
      0f32,           0f32,           1f32,   0f32,
      pos.x.to_f32,   pos.y.to_f32,   0f32,   1f32,
    })
  end
end
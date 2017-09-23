struct Boleite::Rect(Type)
  @left : Type
  @top : Type
  @width : Type
  @height : Type

  property left, top, width, height

  def initialize()
    @left = Type.new(0)
    @top = Type.new(0)
    @width = Type.new(0)
    @height = Type.new(0)
  end

  def initialize(@left, @top, @width, @height)
  end

  def initialize(pos, size)
    @left, @top = pos.x, pos.y
    @width, @height = size.x, size.y
  end

  def initialize(vec)
    @left, @top = vec.x, vec.y
    @width, @height = vec.z, vec.w
  end

  def contains(x, y) : Bool
    min, max = bounds
    x >= min.x && x < max.x && y >= min.y && y < max.y
  end

  def contains(point) : Bool
    contains(point.x, point.y)
  end

  def intersects(other) : Rect(Type) | Bool
    my_min, my_max = bounds
    other_min, other_max = other.bounds

    inter_min = VectorImp(Type, 2).new Math.max(my_min.x, other_min.x), Math.max(my_min.y, other_min.y)
    inter_max = VectorImp(Type, 2).new Math.min(my_max.x, other_max.x), Math.min(my_max.y, other_max.y)
    if inter_min.x < inter_max.x && inter_min.y < inter_max.y
      Rect(Type).new(inter_min, inter_max - inter_min)
    else
      false
    end
  end

  def bounds
    min_x = Math.min @left, @left + @width
    max_x = Math.max @left, @left + @width
    min_y = Math.min @top, @top + @height
    max_y = Math.max @top, @top + @height
    return VectorImp(Type, 2).new(min_x, min_y), VectorImp(Type, 2).new(max_x, max_y)
  end

  def shrink(amount)
    @left += amount
    @top += amount
    @width -= amount * 2
    @height -= amount * 2
  end

  def expand(amount)
    @left -= amount * 2
    @top -= amount * 2
    @width += amount
    @height += amount
  end
end

module Boleite
  alias Recti8   = Rect(Int8)
  alias Recti16  = Rect(Int16)
  alias Recti32  = Rect(Int32)
  alias Recti64  = Rect(Int64)

  alias Rectf32  = Rect(Float32)
  alias Rectf64  = Rect(Float64)

  alias IntRect = Recti32
  alias FloatRect = Rectf64
end
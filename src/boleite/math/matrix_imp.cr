struct Boleite::MatrixImp(Type, Dimension, Size)
  SIZE = Size
  DIMENSION = Dimension
  TYPE = Type

  private macro to_coord(index)
    Vector2u8.new({{index}}.to_u8 % Dimension, {{index}}.to_u8 / Dimension)
  end

  private macro to_index(x, y)
    {{y}} + Dimension * {{x}}
  end
  
  def self.identity : self
    self.new()
  end

  @elements : StaticArray(Type, Size)

  def initialize()
    @elements = StaticArray(Type, Size).new do |index|
      coord = to_coord(index)
      if coord.x == coord.y
        Type.new(1)
      else
        Type.new(0)
      end
    end
  end

  def initialize(@elements : StaticArray(Type, Size))
  end

  def initialize(&block)
    @elements = StaticArray(Type, Size).new(Type.zero)
    @elements.map_with_index! do |value, index|
      yield index
    end
  end
  
  def initialize(*args)
    @elements = StaticArray(Type, Size).new(Type.zero)
    args.each_index do |index|
      @elements[index] = args[index]
    end
  end

  def map
    cpy = self.class.new do |index|
      yield @elements[index]
    end
  end

  def each
    @elements.each { |v| yield v }
  end

  def each_index
    @elements.each_index { |v| yield v }
  end

  def [](index)
    @elements[index]
  end

  def [](x, y)
    @elements[to_index(x, y)]
  end

  def []=(index, value)
    @elements[index] = value
  end

  def []=(x, y, value)
    @elements[to_index(x, y)] = value
  end

  def ==(other : self)
    @elements = other.elements
  end

  protected def elements
    @elements
  end
end

module Boleite
  alias Matrix33f32  = MatrixImp(Float32, 3, 9)
  alias Matrix33f64  = MatrixImp(Float64, 3, 9)
  alias Matrix44f32  = MatrixImp(Float32, 4, 16)
  alias Matrix44f64  = MatrixImp(Float64, 4, 16)

  alias Matrix33  = Matrix33f64
  alias Matrix44  = Matrix44f64
end

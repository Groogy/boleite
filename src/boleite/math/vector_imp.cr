struct Boleite::VectorImp(Type, Size)
  SIZE = Size
  TYPE = Type

  def self.zero : self
    self.new(StaticArray(Type, Size).new(Type.new(0)))
  end

  def self.one : self
    self.new(StaticArray(Type, Size).new(Type.new(1)))
  end

  @elements : StaticArray(Type, Size)

  def initialize()
    @elements = StaticArray(Type, Size).new(Type.zero)
  end

  def initialize(vec : VectorImp(U, Size)) forall U
    @elements = StaticArray(Type, Size).new do |index|
      Type.new(vec[index])
    end
  end

  def initialize(@elements : StaticArray(Type, Size))
  end

  def initialize(elements : Array(Type))
    @elements = StaticArray(Type, Size).new do |index|
      elements[index]
    end
  end

  def initialize(&block)
    @elements = StaticArray(Type, Size).new do |index|
      yield index
    end
  end
  
  def initialize(*args)
    @elements = StaticArray(Type, Size).new do |index|
      Type.new args[index]
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

  def sum
    @elements.sum { |v| yield v }
  end

  def [](index)
    @elements[index]
  end

  def []=(index, value)
    @elements[index] = value
  end

  def ==(other : self)
    @elements == other.elements
  end

  protected def elements
    @elements
  end

  private macro def_vector_property(name, index)
    def {{name.id}}
      @elements[{{index}}]
    end

    def {{name.id}}=(val)
      @elements[{{index}}] = val
    end
  end

  def_vector_property(:x, 0)
  def_vector_property(:y, 1)
  def_vector_property(:z, 2)
  def_vector_property(:w, 3)

  def_vector_property(:r, 0)
  def_vector_property(:g, 1)
  def_vector_property(:b, 2)
  def_vector_property(:a, 3)

  private macro def_vector_math(operator, arg_type)
    def {{operator.id}}(other : {{arg_type}}) : self
      self.class.new().do_math(self, other) do |a, b|
        a.{{operator.id}}(b)
      end
    end
  end

  def_vector_math(:+, VectorImp(Type, Size))
  def_vector_math(:-, VectorImp(Type, Size))
  def_vector_math(:*, VectorImp(Type, Size))
  def_vector_math(:/, VectorImp(Type, Size))
  def_vector_math(://, VectorImp(Type, Size))
  def_vector_math(:+, Type)
  def_vector_math(:-, Type)
  def_vector_math(:*, Type)
  def_vector_math(:/, Type)
  def_vector_math(://, Type)

  def -()
    self.class.new do |index|
      -self[index]
    end
  end

  protected def do_math(a : self, b : self, &block) : self
    @elements.each_index do |i|
      @elements[i] = yield a[i], b[i]
    end
    self
  end

  protected def do_math(a : self, b : Type, &block) : self
    @elements.each_index do |i|
      @elements[i] = yield a[i], b
    end
    self
  end

  private macro def_conv_meth(name, type)
    {% if type == TYPE %}
      def {{name}}
        self
      end  
    {% else %}
      def {{name}}
        VectorImp({{type}}, Size).new(
          StaticArray({{type}}, Size).new { |index|
            @elements[index].{{name}}
          }
        )
      end
    {% end %}
  end

  def_conv_meth(to_i8,  Int8)
  def_conv_meth(to_i16, Int16)
  def_conv_meth(to_i32, Int32)
  def_conv_meth(to_i64, Int64)

  def_conv_meth(to_u8,  UInt8)
  def_conv_meth(to_u16, UInt16)
  def_conv_meth(to_u32, UInt32)
  def_conv_meth(to_u64, UInt64)

  def_conv_meth(to_f32, Float32)
  def_conv_meth(to_f64, Float64)

  def_conv_meth(to_i, Int32)
  def_conv_meth(to_u, UInt32)
  def_conv_meth(to_f, Float64)

  def to_s(io : IO)
    io << "Vec"
    io << {% SIZE %}
    io << "{"
    @elements.join ", ", io, &.inspect(io)
    io << "}"
  end
end

module Boleite
  alias Vector2i8   = VectorImp(Int8,    2)
  alias Vector2i16  = VectorImp(Int16,   2)
  alias Vector2i32  = VectorImp(Int32,   2)
  alias Vector2i64  = VectorImp(Int64,   2)
  alias Vector2u8   = VectorImp(UInt8,   2)
  alias Vector2u16  = VectorImp(UInt16,  2)
  alias Vector2u32  = VectorImp(UInt32,  2)
  alias Vector2u64  = VectorImp(UInt64,  2)
  alias Vector2f32  = VectorImp(Float32, 2)
  alias Vector2f64  = VectorImp(Float64, 2)

  alias Vector2i  = Vector2i32
  alias Vector2u  = Vector2u32
  alias Vector2f  = Vector2f64

  alias Vector3i8   = VectorImp(Int8,    3)
  alias Vector3i16  = VectorImp(Int16,   3)
  alias Vector3i32  = VectorImp(Int32,   3)
  alias Vector3i64  = VectorImp(Int64,   3)
  alias Vector3u8   = VectorImp(UInt8,   3)
  alias Vector3u16  = VectorImp(UInt16,  3)
  alias Vector3u32  = VectorImp(UInt32,  3)
  alias Vector3u64  = VectorImp(UInt64,  3)
  alias Vector3f32  = VectorImp(Float32, 3)
  alias Vector3f64  = VectorImp(Float64, 3)

  alias Vector3i  = Vector3i32
  alias Vector3u  = Vector3u32
  alias Vector3f  = Vector3f64

  alias Vector4i8   = VectorImp(Int8,    4)
  alias Vector4i16  = VectorImp(Int16,   4)
  alias Vector4i32  = VectorImp(Int32,   4)
  alias Vector4i64  = VectorImp(Int64,   4)
  alias Vector4u8   = VectorImp(UInt8,   4)
  alias Vector4u16  = VectorImp(UInt16,  4)
  alias Vector4u32  = VectorImp(UInt32,  4)
  alias Vector4u64  = VectorImp(UInt64,  4)
  alias Vector4f32  = VectorImp(Float32, 4)
  alias Vector4f64  = VectorImp(Float64, 4)

  alias Vector4i  = Vector4i32
  alias Vector4u  = Vector4u32
  alias Vector4f  = Vector4f64

  alias Color32f  = Vector4f32
  alias Color64f  = Vector4f64
  alias Colorf    = Color32f

  alias Color8i    = Vector4u8
  alias Colori     = Color8i
end
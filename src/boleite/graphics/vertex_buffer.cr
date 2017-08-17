module Boleite
  enum Primitive
    Points
    Lines
    LinesStrip
    Triangles
    TrianglesStrip
  end

  abstract struct Vertex
  end

  struct VertexAttribute
    enum Type
      Float
      Double
      Int
    end

    property :size
    property :type
    property :stride
    property :offset

    def initialize
      @size = 0
      @type = Type::Float
      @stride = 0_u32
      @offset = 0_u32
    end

    def initialize(@size, @type, @stride, @offset)
    end

    def initialize(@size, type : Symbol, @stride, @offset)
      @type = case type
      when :float
        Type::Float
      when :double
        Type::Double
      when :int
        Type::Int
      else
        raise ArgumentError.new("Invalid symbol given! Got #{type}")
      end
    end

    def type_size : UInt32
      size = case @type
      when Type::Float
        sizeof(Float32)
      when Type::Double
        sizeof(Float64)
      when Type::Int
        sizeof(Int32)
      else
        sizeof(Float32) # Should never happen but 4 bytes should be default
      end
      size.to_u32
    end
  end

  struct VertexLayout
    @attributes = [] of VertexAttribute

    getter :attributes

    def initialize
    end

    def initialize(@attributes)
    end

    def vertex_size
      @attributes.sum do |attribute|
        attribute.type_size * attribute.size
      end
    end
  end

  abstract class VertexBufferObject
    @buffers = [] of VertexBuffer
    @primitive = Primitive::Triangles
    @layout = VertexLayout.new
    @update_layout = true

    property :primitive

    def layout
      @layout
    end

    def layout=(layout)
      @layout = layout
      @update_layout = true
    end

    def create_buffer()
      buffer = activate { allocate_buffer }
      @buffers << buffer
      buffer
    end

    def get_buffer(index)
      @buffers[index]
    end

    def num_vertices
      size = @layout.vertex_size
      if size <= 0
        0
      else
        total_buffer_size / size
      end
    end

    def total_buffer_size
      @buffers.sum do |buffer|
        buffer.size
      end
    end

    abstract def allocate_buffer : VertexBuffer 
    abstract def render
    abstract def update_layout
    abstract def activate(&block)
  end

  abstract class VertexBuffer
    @data = [] of UInt8
    @rebuild = true

    def add_data(vertex : Vertex) : Void
      vertex_size = sizeof(typeof(vertex))
      data = pointerof(vertex).as(UInt8*).to_slice(vertex_size)
      add_data(data)
    end

    def add_data(slice : Slice(UInt8)) : Void
      slice.each do |byte|
        @data << byte
      end
      @rebuild = true
    end

    def size
      @data.size * sizeof(UInt8)
    end

    def needs_rebuild?
      @rebuild
    end

    abstract def build
  end
end
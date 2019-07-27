enum Boleite::Primitive
  Points
  Lines
  LinesStrip
  Triangles
  TrianglesStrip
  TriangleFan
end

abstract struct Boleite::Vertex
end

struct Boleite::VertexAttribute
  enum Type
    Float
    Double
    Int
  end

  property buffer
  property size
  property type
  property stride
  property offset
  property frequency

  def initialize
    @buffer = 0
    @size = 0
    @type = Type::Float
    @stride = 0_u32
    @offset = 0_u32
    @frequency = 0_u32
  end

  def initialize(@buffer, @size, @type, @stride, @offset, @frequency)
  end

  def initialize(@buffer, @size, type : Symbol, @stride, @offset, @frequency)
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

struct Boleite::VertexLayout
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

abstract class Boleite::VertexBufferObject
  @buffers = [] of VertexBuffer
  @tmp_buffers = [] of VertexBuffer
  @primitive = Primitive::Triangles
  @layout = VertexLayout.new
  @update_layout = true
  @indices_buffer : Int32?

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
    attach_buffer buffer
  end

  def attach_buffer(buffer, temp = false)
    @buffers << buffer
    @tmp_buffers << buffer if temp
    @update_layout = true
    buffer
  end

  def get_buffer(index)
    @buffers[index]
  end

  def set_indices(index)
    if tmp = @indices_buffer
      @buffers[tmp].set_vertices_target
    end
    @indices_buffer = index
    @buffers[index].set_indices_target
  end

  def set_indices(val : Nil)
    if tmp = @indices_buffer
      @buffers[tmp].set_vertices_target
    end
    @indices_buffer = nil
  end

  def num_vertices
    if tmp = @indices_buffer
      @buffers[tmp].size / sizeof(Int32)
    else
      size = @layout.vertex_size
      if size <= 0
        0
      else
        total_buffer_size / size
      end
    end
  end

  def total_buffer_size
    @buffers.sum do |buffer|
      buffer.size
    end
  end

  abstract def allocate_buffer : VertexBuffer 
  abstract def render(instances)
  abstract def update_layout
  abstract def activate(&block)

  private def clear_tmp_buffers
    @layout.attributes.each do |attribute|
      buffer = @buffers[attribute.buffer]
      if @tmp_buffers.includes? buffer
        @buffers.delete buffer
        @update_layout = true
      end
    end
    @tmp_buffers.clear
  end
end

abstract class Boleite::VertexBuffer
  @data = [] of UInt8
  @rebuild = true

  def add_data(vertex : Vertex) : Void
    vertex_size = sizeof(typeof(vertex))
    data = pointerof(vertex).as(UInt8*).to_slice(vertex_size)
    add_data data
  end

  def add_data(index : Int32) : Void
    size = sizeof(Int32)
    data = pointerof(index).as(UInt8*).to_slice(size)
    add_data data
  end

  def add_data(index : UInt32) : Void
    size = sizeof(UInt32)
    data = pointerof(index).as(UInt8*).to_slice(size)
    add_data data
  end

  def add_data(value : Float32) : Void
    size = sizeof(Float32)
    data = pointerof(value).as(UInt8*).to_slice(size)
    add_data data
  end

  def add_data(slice : Slice(UInt8)) : Void
    @data.concat slice
    @rebuild = true
  end

  def add_data(*args) : Void
    args.each { |a| add_data a }
  end

  def clear : Void
    @data.clear
  end

  def size
    @data.size * sizeof(UInt8)
  end

  def needs_rebuild?
    @rebuild
  end

  abstract def set_vertices_target
  abstract def set_indices_target
  abstract def build
end

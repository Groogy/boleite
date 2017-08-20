class Boleite::Private::OpenGLVertexBufferObject < Boleite::VertexBufferObject
  @object_id : LibGL::UInt = 0_u32

  def initialize
    @activated = false
    GL.safe_call { LibGL.genVertexArrays 1, pointerof(@object_id) }
    super
  end

  def finalize
    GL.safe_call { LibGL.deleteVertexArrays 1, pointerof(@object_id) }
  end

  def allocate_buffer : VertexBuffer 
    buf = activate { OpenGLVertexBuffer.new }
  end
  
  def render
    activate do
      @buffers.each do |buffer|
        buffer.activate
        buffer.build
      end
      update_layout

      primitive = self.class.translate_primitive(@primitive)
      GL.safe_call { LibGL.drawArrays primitive, 0, num_vertices }
    end
  end

  def update_layout
    if @update_layout
      activate do
        @layout.attributes.each_index do |index|
          attribute = @layout.attributes[index]
          attribute_type = self.class.translate_type(attribute.type)
          attribute_offset = Pointer(Void).new(attribute.offset)
          GL.safe_call { LibGL.enableVertexAttribArray index }
          GL.safe_call { LibGL.vertexAttribPointer index, attribute.size, attribute_type, LibGL::FALSE, attribute.stride, attribute_offset }
        end
      end
      @update_layout = false
    end
  end
  
  def activate(&block)
    was_activated = @activated
    GL.safe_call { LibGL.bindVertexArray @object_id } unless was_activated
    @activated = true
    result = yield
    @activated = false unless was_activated
    GL.safe_call { LibGL.bindVertexArray 0 } unless was_activated
    result
  end

  def self.translate_primitive(primitive : Primitive)
    case primitive
    when Primitive::Points; LibGL::POINTS
    when Primitive::Lines; LibGL::LINES
    when Primitive::LinesStrip; LibGL::LINE_STRIP
    when Primitive::Triangles; LibGL::TRIANGLES
    when Primitive::TrianglesStrip; LibGL::TRIANGLE_STRIP
    else raise ArgumentError.new "Invalid primitive given! Received #{primitive}"
    end
  end

  def self.translate_type(type : VertexAttribute::Type)
    case type
    when VertexAttribute::Type::Float;  LibGL::FLOAT
    when VertexAttribute::Type::Double; LibGL::DOUBLE
    when VertexAttribute::Type::Int;    LibGL::INT
    else raise ArgumentError.new "Invalid type given! Received #{type}"
    end
  end
end

class Boleite::Private::OpenGLVertexBuffer < Boleite::VertexBuffer
  @buffer_id : LibGL::UInt = 0_u32
  
  def initialize
    GL.safe_call { LibGL.genBuffers 1, pointerof(@buffer_id) }
  end

  def finalize
    GL.safe_call { LibGL.deleteBuffers 1, pointerof(@buffer_id) }
  end

  def activate
    GL.safe_call { LibGL.bindBuffer LibGL::ARRAY_BUFFER, @buffer_id }
  end
  
  def build
    if needs_rebuild?
      activate
      GL.safe_call { LibGL.bufferData LibGL::ARRAY_BUFFER, size, @data.to_unsafe, LibGL::STATIC_DRAW }
      @rebuild = false
    end        
  end
end

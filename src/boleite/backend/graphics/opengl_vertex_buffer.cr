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
    OpenGLVertexBuffer.new
  end
  
  def render(instances)
    activate do
      @buffers.each do |buffer|
        buffer.build
      end
      update_layout

      primitive = self.class.translate_primitive(@primitive)
      if @indices_buffer
        GL.safe_call { LibGL.drawElementsInstanced primitive, num_vertices, LibGL::UNSIGNED_INT, nil, instances }
      else
        GL.safe_call { LibGL.drawArraysInstanced primitive, 0, num_vertices, instances }
      end

      clear_tmp_buffers
    end
  end

  def update_layout
    if @update_layout
      activate do
        @layout.attributes.each_index do |index|
          attribute = @layout.attributes[index]
          attribute_type = self.class.translate_type(attribute.type)
          attribute_offset = Pointer(Void).new(attribute.offset)
          buffer = @buffers[attribute.buffer]
          buffer.activate
          GL.safe_call { LibGL.enableVertexAttribArray index }
          GL.safe_call { LibGL.vertexAttribPointer index, attribute.size, attribute_type, LibGL::FALSE, attribute.stride, attribute_offset }
          GL.safe_call { LibGL.vertexAttribDivisor index, attribute.frequency }
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
    when Primitive::TriangleFan; LibGL::TRIANGLE_FAN
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
  @target = LibGL::ARRAY_BUFFER
  
  def initialize
    GL.safe_call { LibGL.genBuffers 1, pointerof(@buffer_id) }
  end

  def finalize
    GL.safe_call { LibGL.deleteBuffers 1, pointerof(@buffer_id) }
  end

  def activate
    GL.safe_call { LibGL.bindBuffer @target, @buffer_id }
  end

  def set_vertices_target
    @target = LibGL::ARRAY_BUFFER
  end

  def set_indices_target
    @target = LibGL::ELEMENT_ARRAY_BUFFER
  end
  
  def build
    if needs_rebuild?
      activate
      GL.safe_call { LibGL.bufferData @target, size, @data.to_unsafe, LibGL::STATIC_DRAW }
      @rebuild = false
    end        
  end
end

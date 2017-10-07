abstract struct Boleite::Vertex
end

class Boleite::Sprite
  struct Vertex < Vertex
    @data = Vector2f32.zero
  
    def initialize(x, y)
      @data = Vector2f32.new(x, y)
    end
  end

  struct Vertices
    @@vertices : VertexBufferObject?
    @@shader : Shader?

    @uv_buffer : VertexBuffer?
    @uv_vertices = StaticArray(Vertex, 4).new(Vertex.new(0f32, 0f32))

    def get_vertices(gfx) : VertexBufferObject
      vertices = @@vertices
      if vertices.nil?
        vertices = create_vertices(gfx)
        @@vertices = vertices
      end
      vertices
    end
  
    def get_uv(gfx) : VertexBuffer
      buffer = @uv_buffer
      if buffer.nil?
        buffer = gfx.create_vertex_buffer
        @uv_buffer = buffer
      end
      buffer.clear
      @uv_vertices.each { |uv| buffer.add_data uv }
      buffer
    end
  
    def create_vertices(gfx) : VertexBufferObject
      vertices = [
        Vertex.new(0.0f32, 0.0f32),
        Vertex.new(0.0f32, 1.0f32),
        Vertex.new(1.0f32, 0.0f32),
        Vertex.new(1.0f32, 1.0f32),
      ]
    
      layout = VertexLayout.new [
        VertexAttribute.new(0, 2, :float, 8_u32, 0_u32, 0_u32),
        VertexAttribute.new(1, 2, :float, 8_u32, 0_u32, 0_u32),
      ]
      vbo = gfx.create_vertex_buffer_object
      vbo.layout = layout
      vbo.primitive = Primitive::TrianglesStrip
      buffer = vbo.create_buffer
      vertices.each { |vertex| buffer.add_data vertex }
      vbo
    end
  
    def get_shader(gfx) : Shader
      shader = @@shader
      if shader.nil?
        shader = create_shader(gfx)
        @@shader = shader
      end
      shader
    end
  
    def create_shader(gfx) : Shader
      source = {{`cat #{__DIR__}/sprite.shader`.stringify }}
      parser = ShaderParser.new
      parser.parse source
      gfx.create_shader(parser)
    end

    def update_uv_vertices(size, rect)
      size = size.to_f32
      tex_min, tex_max = rect.bounds
      tex_min = tex_min.to_f32 / size
      tex_max = tex_max.to_f32 / size
  
      @uv_vertices[0] = Vertex.new(tex_min.x, tex_max.y)
      @uv_vertices[1] = Vertex.new(tex_min.x, tex_min.y)
      @uv_vertices[2] = Vertex.new(tex_max.x, tex_max.y)
      @uv_vertices[3] = Vertex.new(tex_max.x, tex_min.y)
    end
  end
end
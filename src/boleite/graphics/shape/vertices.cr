abstract struct Boleite::Vertex
end

class Boleite::Shape
  struct Vertex < Vertex
    @pos : Vector2f32

    getter pos
  
    def initialize(@pos)
    end
  end

  struct Vertices
    @@shader : Shader?

    @vbo : VertexBufferObject?
    @vertices = [] of Vertex
    @rebuild = true

    def add(pos)
      @vertices << Vertex.new pos
      @rebuild = true
    end

    def set(index, pos)
      @vertices[index] = Vertex.new pos
      @rebuild = true
    end

    def get(index)
      @vertices[index].pos
    end

    def size
      @vertices.size
    end

    def clear
      @vertices.clear
      @rebuild = true
    end

    def get_vertices(gfx) : VertexBufferObject
      vbo = @vbo
      if vbo.nil?
        vbo = create_vertices(gfx)
        @vbo = vbo
      end
      if @rebuild
        update_vertices vbo
        @rebuild = false
      end
      vbo
    end
  
    def create_vertices(gfx) : VertexBufferObject
      layout = VertexLayout.new [
        VertexAttribute.new(0, 2, :float, 8u32, 0u32, 0u32),
      ]
      vbo = gfx.create_vertex_buffer_object
      vbo.layout = layout
      vbo.primitive = Primitive::Triangles
      vbo.create_buffer
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
      source = {{`cat #{__DIR__}/shape.shader`.stringify }}
      parser = ShaderParser.new
      parser.parse source
      gfx.create_shader(parser)
    end

    def update_vertices(vbo)
      buffer = vbo.get_buffer(0)
      buffer.clear
      @vertices.each do |vertex|
        buffer.add_data vertex
      end
    end
  end
end
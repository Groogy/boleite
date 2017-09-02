abstract struct Boleite::Vertex
end

class Boleite::Sprite
  include Drawable

  struct Vertex < Vertex
    @pos = Vector2f32.zero
    @uv  = Vector2f32.zero
  
    def initialize(pos, uv)
      @pos   = Vector2f32.new(pos)
      @uv    = Vector2f32.new(uv)
    end
  end

  @@vertices : VertexBufferObject?
  @@shader : Shader?

  property texture

  def initialize(@texture : Texture)
  end

  protected def internal_render(renderer, transform)
    vertices = get_vertices(renderer.gfx)
    shader = get_shader(renderer.gfx)
    drawcall = DrawCallContext.new vertices, shader, transform
    drawcall.uniforms["colorTexture"] = texture
    renderer.draw drawcall
  end

  private def get_vertices(gfx) : VertexBufferObject
    vertices = @@vertices
    if vertices.nil?
      vertices = create_vertices(gfx)
      @@vertices = vertices
    end
    vertices
  end

  private def create_vertices(gfx) : VertexBufferObject
    vertices = [
      Vertex.new([0.0f32, 0.0f32], [0.0f32, 1.0f32]),
      Vertex.new([0.0f32, 600.0f32], [0.0f32, 0.0f32]),
      Vertex.new([600.0f32, 0.0f32], [1.0f32, 1.0f32]),
      Vertex.new([600.0f32, 600.0f32], [1.0f32, 0.0f32]),
    ]
  
    layout = VertexLayout.new [
      VertexAttribute.new(2, :float, 16_u32, 0_u32),
      VertexAttribute.new(2, :float, 16_u32, 8_u32),
    ]
    vbo = gfx.create_vertex_buffer_object
    vbo.layout = layout
    vbo.primitive = Primitive::TrianglesStrip
    buffer = vbo.create_buffer
    vertices.each { |vertex| buffer.add_data vertex }
    vbo
  end

  private def get_shader(gfx) : Shader
    shader = @@shader
    if shader.nil?
      shader = create_shader(gfx)
      @@shader = shader
    end
    shader
  end

  private def create_shader(gfx) : Shader
    source = <<-SRC
    #version 450
    values
    {
      worldTransform = world;
      viewTransform = camera;
      projectionTransform = projection;
    }

    depth
    {
      enabled = false;
      function = Always;
    }

    vertex
    {
      layout(location = 0) in vec2 position;
      layout(location = 1) in vec2 uv;
      uniform mat4 world;
      uniform mat4 camera;
      uniform mat4 projection;
      out VertexData {
        vec2 uv;
      } outputVertex;
      void main()
      {
        vec4 worldPos = world * vec4(position, 0, 1);
        vec4 viewPos = camera * worldPos;
        gl_Position = projection * viewPos;
        outputVertex.uv = uv;
      }
    }

    fragment
    {
      layout(location = 0) out vec4 outputColor;
      uniform sampler2D colorTexture;
      in VertexData {
        vec2 uv;
      } inputVertex;
      void main()
      {
        vec4 color = texture(colorTexture, inputVertex.uv);
        outputColor = color;
      }
    }
    SRC
    parser = ShaderParser.new
    parser.parse source
    gfx.create_shader(parser)
  end
end
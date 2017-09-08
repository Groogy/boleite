abstract struct Boleite::Vertex
end

module Boleite::Transformable
end

class Boleite::Sprite
  include Drawable
  include Transformable

  struct Vertex < Vertex
    @data = Vector2f32.zero
  
    def initialize(x, y)
      @data = Vector2f32.new(x, y)
    end
  end

  @@vertices : VertexBufferObject?
  @@shader : Shader?

  property texture, size

  @size : Vector2u
  @uv_buffer : VertexBuffer?
  @uv_vertices = StaticArray(Vertex, 4).new(Vertex.new(0f32, 0f32))

  def initialize(@texture : Texture)
    @size = @texture.size
    @texture_rect = IntRect.new(0, 0, @size.x.to_i, @size.y.to_i)
    update_uv_vertices
  end

  def texture_rect
    @texture_rect
  end

  def texture_rect=(rect)
    @texture_rect = rect
    update_uv_vertices
  end

  protected def internal_render(renderer, transform)
    vertices = get_vertices(renderer.gfx)
    shader = get_shader(renderer.gfx)
    uv = get_uv(renderer.gfx)
    scale_transform = Matrix.scale Matrix44f32.identity, Vector4f32.new(@size.x.to_f32, @size.y.to_f32, 1f32, 1f32)
    transform = Matrix.mul transform, self.transformation
    transform = Matrix.mul scale_transform, transform
    drawcall = DrawCallContext.new vertices, shader, transform
    drawcall.uniforms["colorTexture"] = texture
    drawcall.buffers << uv
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

  private def get_uv(gfx) : VertexBuffer
    buffer = @uv_buffer
    if buffer.nil?
      buffer = gfx.create_vertex_buffer
      @uv_buffer = buffer
    end
    buffer.clear
    @uv_vertices.each { |uv| buffer.add_data uv }
    buffer
  end

  private def create_vertices(gfx) : VertexBufferObject
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

  private def update_uv_vertices
    tex_size = @texture.size.to_f32
    tex_min, tex_max = @texture_rect.bounds
    tex_min = tex_min.to_f32 / tex_size
    tex_max = tex_max.to_f32 / tex_size

    @uv_vertices[0] = Vertex.new(tex_min.x, tex_max.y)
    @uv_vertices[1] = Vertex.new(tex_min.x, tex_min.y)
    @uv_vertices[2] = Vertex.new(tex_max.x, tex_max.y)
    @uv_vertices[3] = Vertex.new(tex_max.x, tex_min.y)
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
        outputVertex.uv = vec2(uv.x, 1-uv.y);
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
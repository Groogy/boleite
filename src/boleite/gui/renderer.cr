abstract class Boleite::Renderer
end

class Boleite::GUI
  class Renderer < Boleite::Renderer
    include CrystalClear

    struct Vertex < Vertex
      @pos = Vector2f32.zero
      @uv = Vector2f32.zero
    
      def initialize(x, y, u, v)
        @pos = Vector2f32.new(x, y)
        @uv  = Vector2f32.new(u, v)
      end
    end

    @framebuffer : FrameBuffer
    @texture : Texture
    @vertices : VertexBufferObject
    @paste_shader : Shader

    def initialize(@gfx : GraphicsContext, @camera : Camera)
      target = @gfx.main_target
      @framebuffer = @gfx.create_frame_buffer
      @texture = @gfx.create_texture
      @texture.create target.width, target.height, Texture::Format::RGBA, Texture::Type::Integer8
      @framebuffer.attach_buffer @texture, :color, 0u8
      @vertices = @gfx.create_vertex_buffer_object
      @paste_shader = create_paste_shader @gfx
      create_vertices
    end

    def create_paste_shader(gfx) : Shader
      source = {{`cat #{__DIR__}/paste.shader`.stringify }}
      parser = ShaderParser.new
      parser.parse source
      gfx.create_shader(parser)
    end

    def create_vertices
      layout = Boleite::VertexLayout.new [
        Boleite::VertexAttribute.new(0, 2, :float, 16u32, 0u32, 0u32),
        Boleite::VertexAttribute.new(0, 2, :float, 16u32, 8u32, 0u32)
      ]
      @vertices.layout = layout
      @vertices.primitive = Boleite::Primitive::TrianglesStrip
      buffer = @vertices.create_buffer
      buffer.add_data Vertex.new(-1f32, -1f32, 0f32, 0f32)
      buffer.add_data Vertex.new( 1f32, -1f32, 1f32, 0f32)
      buffer.add_data Vertex.new(-1f32,  1f32, 0f32, 1f32)
      buffer.add_data Vertex.new( 1f32,  1f32, 1f32, 1f32)
    end

    def clear(color : Colorf)
      @framebuffer.activate do
        @gfx.clear color
      end
    end

    requires drawcall.shader
    def draw(drawcall : DrawCallContext)
      @framebuffer.activate do
        if shader = drawcall.shader
          apply_shader_settings shader, drawcall.transformation, drawcall.uniforms
          drawcall.buffers.each { |buffer| drawcall.vertices.attach_buffer(buffer, true) }
          shader.activate do
            drawcall.vertices.render(1)
          end
        end
      end
    end

    def present
      @paste_shader.set_parameter "colorTexture", @texture
      @paste_shader.activate do
        @vertices.render(1)
      end
    end
  end
end
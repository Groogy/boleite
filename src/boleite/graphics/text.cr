require "./text/formatter.cr"
require "./text/format_rule.cr"

abstract struct Boleite::Vertex
end

module Boleite::Transformable
end

class Boleite::Text
  include Drawable
  include Transformable

  struct Vertex < Vertex
    @pos = Vector2f32.zero
    @uv = Vector2f32.zero
    @color = Vector4f32.zero
  
    def initialize(x, y, u, v, @color)
      @pos = Vector2f32.new(x, y)
      @uv  = Vector2f32.new(u, v)
    end
  end

  class Line
    getter glyphs, top, text
    def initialize(@glyphs : Array(Font::Glyph), @text : String)
      @top = 0.0
      @glyphs.each do |glyph|
        @top = glyph.bounds.height if glyph.bounds.height > @top
      end
    end
  end

  @@shader : Shader?

  property font
  getter text, size, default_color, formatter

  @vertices : VertexBufferObject?
  @font : Font
  @text : String
  @lines = [] of Line
  @size = 12u32
  @rebuild = true
  @default_color = Color.white
  @formatter = Formatter.new

  def initialize(@font, @text = "")
  end

  def text=(val)
    @text = val
    @rebuild = true
    find_glyphs
  end

  def size=(val)
    @size = val
    @rebuild = true
    find_glyphs
  end

  def default_color=(val)
    @default_color = val
    @rebuild = true
  end

  protected def internal_render(renderer, transform)
    vertices = get_vertices renderer.gfx
    shader = get_shader renderer.gfx
    transform = Matrix.mul transform, self.transformation
    drawcall = DrawCallContext.new vertices, shader, transform
    drawcall.uniforms["fontTexture"] = @font.texture_for @size
    renderer.draw drawcall
  end

  private def get_vertices(gfx) : VertexBufferObject
    vertices = @vertices
    if @rebuild || vertices.nil?
      vertices = create_vertices gfx
      @vertices = vertices
      @rebuild = false
    end
    vertices
  end

  private def create_vertices(gfx) : VertexBufferObject
    vertices = build_vertices gfx
    layout = VertexLayout.new [
      VertexAttribute.new(0, 2, :float, 32u32, 0u32,  0u32),
      VertexAttribute.new(0, 2, :float, 32u32, 8u32,  0u32),
      VertexAttribute.new(0, 4, :float, 32u32, 16u32, 0u32),
    ]
    vbo = gfx.create_vertex_buffer_object
    vbo.layout = layout
    vbo.primitive = Primitive::Triangles
    buffer = vbo.create_buffer
    vertices.each { |vertex| buffer.add_data vertex }
    vbo
  end

  private def build_vertices(gfx) : Array(Vertex)
    vertices = [] of Vertex
    texture_size = @font.texture_for(@size).size
    baseline = 0
    @lines.each do |line|
      advance = 0
      colors = @formatter.format(line.text, @default_color)
      prev_glyph = nil
      line.glyphs.each_index do |index|
        glyph = line.glyphs[index]
        create_glyph_vertices vertices, glyph, colors[index], advance, baseline + line.top, texture_size
        kerning = prev_glyph ? @font.get_kerning prev_glyph.code, glyph.code, @size : 0
        advance += glyph.advance + kerning
        prev_glyph = glyph
      end
      baseline += line.top
    end
    vertices
  end

  private def create_glyph_vertices(vertices, glyph, color, advance, top, texture_size)
    top = glyph.bounds.height - top
    min, max = glyph.bounds.bounds
    min, max = min.to_f32, max.to_f32
    tex_min, tex_max = glyph.texture_rect.bounds
    tex_min, tex_max = tex_min.to_f32 / texture_size.to_f32, tex_max.to_f32 / texture_size.to_f32
    tex_min.y = 1 - tex_min.y
    tex_max.y = 1 - tex_max.y
    vertices << Vertex.new(min.x + advance, min.y - top, tex_min.x, tex_min.y, color)
    vertices << Vertex.new(min.x + advance, max.y - top, tex_min.x, tex_max.y, color)
    vertices << Vertex.new(max.x + advance, min.y - top, tex_max.x, tex_min.y, color)
    vertices << Vertex.new(min.x + advance, max.y - top, tex_min.x, tex_max.y, color)
    vertices << Vertex.new(max.x + advance, min.y - top, tex_max.x, tex_min.y, color)
    vertices << Vertex.new(max.x + advance, max.y - top, tex_max.x, tex_max.y, color)
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
    
    blend
    {
      enabled = true;
      function = Add;
      sourceFactor = SourceAlpha;
      destinationFactor = OneMinusSourceAlpha;
    }

    vertex
    {
      layout(location = 0) in vec2 position;
      layout(location = 1) in vec2 uv;
      layout(location = 2) in vec4 color;
      uniform mat4 world;
      uniform mat4 camera;
      uniform mat4 projection;
      out VertexData {
        vec2 uv;
        vec4 color;
      } outputVertex;
      void main()
      {
        vec4 worldPos = world * vec4(position, 0, 1);
        vec4 viewPos = camera * worldPos;
        gl_Position = projection * viewPos;
        outputVertex.uv = vec2(uv.x, 1-uv.y);
        outputVertex.color = color;
      }
    }

    fragment
    {
      layout(location = 0) out vec4 outputColor;
      uniform sampler2D fontTexture;
      in VertexData {
        vec2 uv;
        vec4 color;
      } inputVertex;
      void main()
      {
        float mask = texture(fontTexture, inputVertex.uv).r;
        outputColor = inputVertex.color * mask;
      }
    }
    SRC
    parser = ShaderParser.new
    parser.parse source
    gfx.create_shader(parser)
  end

  private def find_glyphs
    glyph_line = [] of Font::Glyph
    line = ""
    @text.each_char do |char|
      if char == '\n'
        @lines << Line.new glyph_line, line
        glyph_line = [] of Font::Glyph
        line = ""
      else
        glyph_line << @font.get_glyph char, @size
        line += char
      end
    end
    @lines << Line.new glyph_line, line unless glyph_line.empty?
  end
end
abstract struct Boleite::Vertex
end

class Boleite::Text
  struct Vertex < Vertex
    @pos = Vector2f32.zero
    @uv = Vector2f32.zero
    @color = Vector4f32.zero
  
    def initialize(x, y, u, v, @color)
      @pos = Vector2f32.new(x, y)
      @uv  = Vector2f32.new(u, v)
    end
  end

  struct TextData
    getter font, size, lines, formatter, default_color

    @font : Font
    @size : UInt32
    @lines : Array(Line)
    @formatter : Formatter
    @default_color : Colorf

    def initialize(@font, @size, @lines, @formatter, @default_color)
    end
  end

  struct Vertices
    @@shader : Shader?

    @vertices : VertexBufferObject?
    @rebuild = true

    def mark_for_rebuild
      @rebuild = true
    end

    def get_vertices(gfx, data) : VertexBufferObject
      vertices = @vertices
      if @rebuild || vertices.nil?
        vertices = create_vertices gfx, data
        @vertices = vertices
        @rebuild = false
      end
      vertices
    end
  
    def create_vertices(gfx, data) : VertexBufferObject
      vertices = build_vertices gfx, data
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
  
    def build_vertices(gfx, data) : Array(Vertex)
      vertices = [] of Vertex
      texture_size = data.font.texture_for(data.size).size
      baseline = 0
      linespacing = data.font.get_linespacing(data.size)
      data.lines.each do |line|
        baseline += linespacing
        colors = data.formatter.format line.text, data.default_color
        build_line_vertices data.font, vertices, line, colors, baseline, texture_size, data.size
      end
      vertices
    end
  
    def build_line_vertices(font, vertices, line, colors, baseline, texture_size, char_size)
      prev_glyph = nil
      advance = 0
      line.glyphs.zip colors do |glyph, color|
        kerning = 0
        kerning = font.get_kerning prev_glyph.code, glyph.code, char_size if prev_glyph
        create_glyph_vertices vertices, glyph, color, advance, baseline, texture_size
        advance += glyph.advance + kerning
        prev_glyph = glyph
      end
    end
  
    def create_glyph_vertices(vertices, glyph, color, advance, top, texture_size)
      top = glyph.bounds.height - top
      min, max = glyph.bounds.bounds
      min, max = min.to_f32, max.to_f32
      tex_min, tex_max = glyph.texture_rect.bounds
      tex_min, tex_max = tex_min.to_f / texture_size.to_f, tex_max.to_f / texture_size.to_f
      tex_min, tex_max = tex_min.to_f32, tex_max.to_f32
      vertices << Vertex.new(min.x + advance, min.y - top, tex_min.x, tex_min.y, color)
      vertices << Vertex.new(min.x + advance, max.y - top, tex_min.x, tex_max.y, color)
      vertices << Vertex.new(max.x + advance, min.y - top, tex_max.x, tex_min.y, color)
      vertices << Vertex.new(min.x + advance, max.y - top, tex_min.x, tex_max.y, color)
      vertices << Vertex.new(max.x + advance, max.y - top, tex_max.x, tex_max.y, color)
      vertices << Vertex.new(max.x + advance, min.y - top, tex_max.x, tex_min.y, color)
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
      source = {{`cat #{__DIR__}/text.shader`.stringify }}
      parser = ShaderParser.new
      parser.parse source
      gfx.create_shader(parser)
    end
  end
end
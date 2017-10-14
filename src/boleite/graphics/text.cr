require "./text/*"

module Boleite::Transformable
end

class Boleite::Text
  include Drawable
  include Transformable

  class Line
    getter glyphs, top, text
    def initialize(@glyphs : Array(Font::Glyph), @text : String)
      @top = 0.0
      @glyphs.each do |glyph|
        @top = glyph.bounds.height if glyph.bounds.height > @top
      end
    end
  end

  property font
  getter text, size, default_color, formatter

  
  @font : Font
  @text : String
  @lines = [] of Line
  @size = 12u32
  @default_color = Color.white
  @formatter = Formatter.new
  @vertices = Vertices.new

  def initialize(@font, @text = "")
    find_glyphs
  end

  def text=(val)
    @text = val
    @vertices.mark_for_rebuild
    find_glyphs
  end

  def size=(val)
    @size = val
    @vertices.mark_for_rebuild
    find_glyphs
  end

  def default_color=(val)
    @default_color = val
    @vertices.mark_for_rebuild
  end

  protected def internal_render(renderer, transform)
    vertices = @vertices.get_vertices renderer.gfx, TextData.new(@font, @size, @lines, @formatter, @default_color)
    shader = @vertices.get_shader renderer.gfx
    transform = Matrix.mul transform, self.transformation
    drawcall = DrawCallContext.new vertices, shader, transform
    drawcall.uniforms["fontTexture"] = @font.texture_for @size
    renderer.draw drawcall
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
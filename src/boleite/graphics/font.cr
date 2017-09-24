require "./font/glyph.cr"
require "./font/page.cr"
require "./font/row.cr"

class Boleite::Font
  class Error < Exception
  end

  @gfx : GraphicsContext
  @pages = {} of UInt32 => Page

  def initialize(@gfx, file)
    error = LibFreeType.init_FreeType(out @library)
    raise Error.new("Failed initialization of FreeType") if error != LibFreeType::Err_Ok
    error = LibFreeType.new_Face @library, file, 0, out @face
    raise Error.new("Failed to read #{file}") if error != LibFreeType::Err_Ok
    error = LibFreeType.select_Charmap(@face, LibFreeType::Encoding::UNICODE)
    raise Error.new("Failed to select unicode charset for #{file}") if error != LibFreeType::Err_Ok
  end

  def finalize
    LibFreeType.done_Face @face
    LibFreeType.done_FreeType @library
  end

  def texture_for(size) : Texture
    page = get_page size
    page.texture
  end

  def get_glyph(code : Char, size : UInt32)
    page = get_page size
    key = Glyph.generate_hash code
    glyph = page.glyphs[key]?
    if glyph.nil?
      glyph = page.create_glyph code
    end
    return glyph
  end

  def get_kerning(first : Char, second : Char, size : UInt32)
    page = get_page size
    page.get_kerning first, second
  end

  def get_page(size) : Page
    page = @pages[size]?
    unless page
      page = Page.new @face, @gfx, size
      @pages[size] = page
    end
    page
  end
end
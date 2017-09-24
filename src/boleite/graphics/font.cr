class Boleite::Font
  class Error < Exception
  end

  struct Glyph
    property advance, bounds, texture_rect, code

    @advance = 0i64
    @bounds = FloatRect.new
    @texture_rect = IntRect.new
    @code = Char::ZERO

    def self.generate_hash(code) : UInt64
      code.hash.to_i64.to_u64
    end

    def generate_hash : UInt64
      self.class.generate_hash @code
    end
  end

  class Row
    property width, top, height

    @width = 0u32
    @top = 0u32
    @height = 0u32

    def initialize(@top, @height)
    end
  end

  class Page
    property glyphs, texture, next_row, rows

    @gfx : GraphicsContext
    @face : LibFreeType::Face
    @texture : Texture
    @size : UInt32
    @glyphs = {} of UInt64 => Glyph
    @next_row = 0u32
    @rows = [] of Row

    def initialize(@face, @gfx, @size)
      @texture = @gfx.create_texture
      @texture.create 64u32, 64u32, Texture::Format::Red, Texture::Type::Integer8
    end

    def character_size
      @size
    end

    def create_glyph(code) : Glyph
      load_glyph code
      glyph = render_glyph
      glyph.code = code
      @glyphs[glyph.generate_hash] = glyph
    end

    private def apply_size
      error = LibFreeType.set_Pixel_Sizes @face, @size, @size
      raise Error.new("Failed to set charset size to #{@size}") if error != LibFreeType::Err_Ok
    end

    private def load_glyph(code)
      apply_size
      flags = LibFreeType::Load::RENDER
      error = LibFreeType.load_Char @face, code.hash, flags
      raise Error.new("Failed to load glyph for #{code}") if error != LibFreeType::Err_Ok
    end

    private def render_glyph : Glyph
      glyph = Glyph.new
      raw_glyph = @face.value.glyph
      bitmap = raw_glyph.value.bitmap
      glyph.advance = raw_glyph.value.advance.x >> 6
      width, height = bitmap.width + 2, bitmap.rows + 2 # Add padding to glyph space
      glyph.texture_rect = find_glyph_rect(width, height)
      glyph.texture_rect.shrink 1 # Remove the padding
      glyph.bounds.left   = raw_glyph.value.bitmap_left.to_f
      glyph.bounds.top    = raw_glyph.value.bitmap.rows - raw_glyph.value.bitmap_top.to_f
      glyph.bounds.width  = raw_glyph.value.bitmap.width.to_f
      glyph.bounds.height = raw_glyph.value.bitmap.rows.to_f
      render_glyph_to_texture glyph, width, height
      glyph
    end

    private def find_glyph_rect(width, height)
      row = find_row_for width, height
      rect = IntRect.new row.width.to_i, row.top.to_i, width.to_i, height.to_i
      row.width += width
      rect
    end

    private def find_row_for(width, height) : Row
      best_ratio = 0.0
      best_row = nil
      @rows.each do |row|
        ratio = height.to_f / row.height.to_f
        next if ratio < 0.7 || ratio > 1.0
        next if width > @texture.size.x - row.width
        next if ratio < best_ratio
        best_row = row
        best_ratio = ratio
      end
      best_row = create_row(width, height) if best_row.nil?
      best_row
    end

    private def create_row(width, height) : Row
      row_height = height + height / 10
      size = @texture.size
      max_size = @gfx.texture_maximum_size
      while @next_row + row_height >= size.y || width >= size.x
        size = @texture.size * 2u32
        if size.x > max_size && size.y > max_size
          raise Error.new "Font too large, Maximum texture size reached"
        end

        texture = @gfx.create_texture
        texture.create size.x, size.y, Texture::Format::Red, Texture::Type::Integer8
        texture.update @texture
        @texture = texture
      end
      row = Row.new @next_row, row_height
      @rows << row
      @next_row += row_height
      row
    end

    private def render_glyph_to_texture(glyph, width, height) : Nil
      bitmap = @face.value.glyph.value.bitmap  
      buffer = Bytes.new bitmap.buffer, (bitmap.width * bitmap.rows).to_i
      pixels = Bytes.new (width * height).to_i, 0u8
      (1...height-1).each do |y|
        (1...width-1).each do |x|
          index = x + y * width
          pixels[index] = buffer[x - 1]
        end
        buffer += bitmap.pitch
      end
      rect = glyph.texture_rect
      @texture.update(pixels, width, height, rect.left, rect.top, 8)
    end
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

  def get_glyph(code : Char, size : UInt32)
    page = get_page size
    key = Glyph.generate_hash code
    glyph = page.glyphs[key]?
    if glyph.nil?
      glyph = page.create_glyph code
    end
    return glyph
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
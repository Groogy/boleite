class Boleite::Font
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

    def get_kerning(first, second) : Int32
      if @face.value.face_flags & LibFreeType::FaceFlag::KERNING.to_i
        apply_size
        index1 = LibFreeType.get_Char_Index @face, first.hash
        index2 = LibFreeType.get_Char_Index @face, second.hash
        error = LibFreeType.get_Kerning @face, index1, index2, 0, out kerning
        raise Error.new("Failed to fetch kerning between #{first} and #{second}") if error != LibFreeType::Err_Ok
        return kerning.x.to_i unless @face.value.face_flags & LibFreeType::FaceFlag::SCALABLE.to_i
        return (kerning.x >> 6).to_i
      else
        0
      end
    end

    def get_linespacing : Float64
      apply_size
      metrics = @face.value.size.value.metrics
      metrics.height.to_f / (1 << 6).to_f
    end

    private def apply_size
      error = LibFreeType.set_Pixel_Sizes @face, @size, @size
      raise Error.new("Failed to set charset size to #{@size}") if error != LibFreeType::Err_Ok
    end

    private def load_glyph(code)
      apply_size
      flags = LibFreeType::Load::RENDER
      error = LibFreeType.load_Char @face, code.ord, flags
      raise Error.new("Failed to load glyph for #{code}") if error != LibFreeType::Err_Ok
    end

    private def render_glyph : Glyph
      glyph = Glyph.new
      raw_glyph = @face.value.glyph
      bitmap = raw_glyph.value.bitmap
      glyph.advance = raw_glyph.value.advance.x >> 6
      width, height = bitmap.width + 2, bitmap.rows + 2 # Add padding to glyph space
      texture_rect = find_glyph_rect(width, height)
      texture_rect.left += 1
      texture_rect.top += 1
      texture_rect.width -= 2
      texture_rect.height -= 2
      glyph.texture_rect = texture_rect
      bounds = glyph.bounds
      bounds.left   = raw_glyph.value.bitmap_left.to_f
      bounds.top    = raw_glyph.value.bitmap.rows - raw_glyph.value.bitmap_top.to_f
      bounds.width  = raw_glyph.value.bitmap.width.to_f
      bounds.height = raw_glyph.value.bitmap.rows.to_f
      glyph.bounds = bounds
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

      x = rect.left - 1
      y = rect.top - 1
      w = rect.width + 2
      h = rect.height + 2
      @texture.update(pixels, w.to_u32, h.to_u32, x.to_u32, y.to_u32, Texture::Format::Red)
    end
  end
end

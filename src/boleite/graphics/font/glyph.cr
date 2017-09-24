class Boleite::Font
  class Glyph
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
end
abstract class Boleite::Texture
  enum Format
    Red
    RG
    RGB
    RGBA
  end

  enum Type
    Integer8
    Integer16
    Float16
    Float32
  end

  def self.bpp_to_format(bpp)
    case bpp
    when 32; Format::RGBA
    when 24; Format::RGB
    when 16; Format::RG
    when 8; Format::Red
    else
      raise "Unsupported bits per pixel given! (#{bpp})"
    end
  end

  def self.load_file(file, graphics) : Texture
    img = Image.load_file file
    load_image img, graphics
  end

  def self.load_image(img, graphics) : Texture
    texture = graphics.create_texture
    texture.create img.width, img.height, Format::RGBA, Type::Integer8
    texture.update img
    texture
  end

  def update(img : Image) : Void
    size = img.size
    format = Texture.bpp_to_format img.bpp
    update img.pixels, size.x, size.y, 0u32, 0u32, format
  end

  def update(texture : Texture) : Void
    update(texture, 0, 0)
  end

  def update(bytes : Bytes, width : UInt32, height : UInt32, x_dest : UInt32, y_dest : UInt32, format : Format) : Void
    update bytes.pointer(0), width, height, x_dest, y_dest, format
  end

  abstract def create(width : UInt32, height : UInt32, format : Format, type : Type) : Void
  abstract def create_depth(width : UInt32, height : UInt32) : Void

  abstract def update(pixels : Pointer(UInt8), width : UInt32, height : UInt32, x_dest : UInt32, y_dest : UInt32, format : Format) : Void
  abstract def update(pixels : Pointer(Float32), width : UInt32, height : UInt32, x_dest : UInt32, y_dest : UInt32, format : Format) : Void
  abstract def update(texture : Texture, x : UInt32, y : UInt32) : Void

  abstract def size : Vector2u

  abstract def format : Format
  abstract def type : Type

  abstract def is_depth? : Bool
  abstract def is_smooth? : Bool
  abstract def smooth=(val : Bool) : Bool
  
  abstract def is_repeating? : Bool
  abstract def repeating=(val : Bool) : Bool

  abstract def activate(&block)
end

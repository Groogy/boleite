class Boleite::Image
  include CrystalClear
  class Error < Exception
  end
  
  @width : UInt32
  @height : UInt32
  @bpp : UInt32
  @pixels : Pointer(UInt8)

  getter width, height, bpp, pixels

  def self.load_file(file)
    Image.new file
  end

  def initialize(@width, @height, @bpp = 32u32)
    @pixels = Pointer(UInt8).malloc byte_size
  end

  def initialize(@width, @height, @bpp, @pixels)
  end

  def initialize(@width, @height, @bpp, pixels)
    @pixels = pixels.pointer
  end

  def initialize(file : String)
    format = LibFreeImage.getFileType file, 0
    native = LibFreeImage.load format, file, 0
    raise Error.new "Failed to load image #{file}" if native.null?
    initialize(native)
    LibFreeImage.unload native
  end

  def size
    Vector2u.new(@width, @height)
  end

  def byte_size : UInt64
    width.to_u64 * height.to_u64 * bpp.to_u64
  end

  def clone
    self.class.new @width, @height, @bpp, @pixels.clone
  end

  def update(x, y, w, h, color : Colori)
    update IntRect.new(x, y, w, h), color
  end

  def update(rect, color : Colori)
    rect.height.times do |y|
      rect.width.times do |x|
        set_pixel rect.left + x, rect.top + y, color
      end
    end
  end

  requires x >= 0 && x < @width
  requires y >= 0 && y < @height
  def set_pixel(x, y, color : Colori)
    index = (x + y * width) * (@bpp / 8)
    @pixels[index + 0] = color.r if @bpp >= 8
    @pixels[index + 1] = color.g if @bpp >= 16
    @pixels[index + 2] = color.b if @bpp >= 24
    @pixels[index + 3] = color.a if @bpp >= 32
  end

  requires x >= 0 && x < @width
  requires y >= 0 && y < @height
  def set_pixel(x, y, color : Colorf)
    converted = (color * 255).to_u8
    set_pixel x, y, color
  end

  requires x >= 0 && x < @width
  requires y >= 0 && y < @height
  def get_pixel(x, y)
    r, g, b, a = 0u8, 0u8, 0u8, 0u8
    index = (x + y * width) * (@bpp / 8)
    r = @pixels[index + 0] if @bpp >= 8
    g = @pixels[index + 1] if @bpp >= 16
    b = @pixels[index + 2] if @bpp >= 24
    a = @pixels[index + 3] if @bpp >= 32
    Colori.new r, g, b, a
  end

  def fill(color : Colori)
    update 0, 0, width.to_i, height.to_i, color
  end

  protected def initialize(native : LibFreeImage::FIBITMAP*)
    @width = LibFreeImage.getWidth native
    @height = LibFreeImage.getHeight native
    @bpp = LibFreeImage.getBPP native

    ptr = LibFreeImage.getBits native
    pitch = LibFreeImage.getPitch native

    @pixels = Pointer(UInt8).malloc byte_size

    bytes = 0
    @height.times do |y|
      pixel = ptr
      @width.times do |x|
        case @bpp
        when 16; convert_16bit pixel, bytes
        when 24; convert_24bit pixel, bytes
        when 32; convert_32bit pixel, bytes
        end
        pixel += @bpp / 8
        bytes += @bpp / 8
      end
      ptr += pitch
    end
  end

  private def convert_16bit(pixel, index) : Void
    red = pixel[LibFreeImage::RGBA_RED]
    green = pixel[LibFreeImage::RGBA_GREEN]
    @pixels[index + 0] = red
    @pixels[index + 1] = green
  end

  private def convert_24bit(pixel, index) : Void
    red = pixel[LibFreeImage::RGBA_RED]
    green = pixel[LibFreeImage::RGBA_GREEN]
    blue = pixel[LibFreeImage::RGBA_BLUE]
    @pixels[index + 0] = red
    @pixels[index + 1] = green
    @pixels[index + 2] = blue
  end

  private def convert_32bit(pixel, index) : Void
    red = pixel[LibFreeImage::RGBA_RED]
    green = pixel[LibFreeImage::RGBA_GREEN]
    blue = pixel[LibFreeImage::RGBA_BLUE]
    alpha = pixel[LibFreeImage::RGBA_ALPHA]
    @pixels[index + 0] = red
    @pixels[index + 1] = green
    @pixels[index + 2] = blue
    @pixels[index + 3] = alpha
  end
end

class Boleite::Image
  class Error < Exception
  end
  
  @width : UInt32
  @height : UInt32
  @bpp : UInt32
  @pixels : Bytes

  getter width, height, bpp

  def self.load_file(file)
    Image.new file
  end

  def initialize(@width, @height, @bpp = 32)
    @pixels = Bytes.new byte_size
  end

  def initialize(@width, @height, @bpp, @pixels)
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

  def byte_size
    width * height * bpp
  end

  def clone
    self.class.new @width, @height, @bpp, @pixels.clone
  end

  def pixels : Bytes
    @pixels
  end

  protected def initialize(native : LibFreeImage::FIBITMAP*)
    @width = LibFreeImage.getWidth native
    @height = LibFreeImage.getHeight native
    @bpp = LibFreeImage.getBPP native

    ptr = LibFreeImage.getBits native
    pitch = LibFreeImage.getPitch native

    @height.times do |y|
      pixel = ptr
      @width.times do |x|
        case @bpp
        when 16; convert_16bit(pixel)
        when 24; convert_24bit(pixel)
        when 32; convert_32bit(pixel)
        end
        pixel += @bpp / 8
      end
      ptr += pitch
    end
    
    ptr = LibFreeImage.getBits native
    @pixels = Bytes.new byte_size
    @pixels.copy_from ptr, byte_size
  end

  private def convert_16bit(pixel) : Void
    red = pixel[LibFreeImage::RGBA_RED]
    green = pixel[LibFreeImage::RGBA_GREEN]
    pixel[0] = red
    pixel[1] = green
  end

  private def convert_24bit(pixel) : Void
    red = pixel[LibFreeImage::RGBA_RED]
    green = pixel[LibFreeImage::RGBA_GREEN]
    blue = pixel[LibFreeImage::RGBA_BLUE]
    pixel[0] = red
    pixel[1] = green
    pixel[2] = blue
  end

  private def convert_32bit(pixel) : Void
    red = pixel[LibFreeImage::RGBA_RED]
    green = pixel[LibFreeImage::RGBA_GREEN]
    blue = pixel[LibFreeImage::RGBA_BLUE]
    alpha = pixel[LibFreeImage::RGBA_ALPHA]
    pixel[0] = red
    pixel[1] = green
    pixel[2] = blue
    pixel[3] = alpha
  end
end

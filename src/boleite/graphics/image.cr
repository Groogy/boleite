class Boleite::Image
  @width : UInt32
  @height : UInt32
  @bpp : UInt32

  getter width, height, bpp

  def self.load_file(file)
    Image.new file
  end

  def initialize(@width, @height, @bpp = 32)
    @native = LibFreeImage.allocate(@width, @height, @bpp, 0, 0, 0)
  end

  def initialize(file : String)
    @native = LibFreeImage.load LibFreeImage::FORMAT::FIF_BMP, file, 0
    @width = LibFreeImage.getWidth @native
    @height = LibFreeImage.getHeight @native
    @bpp = LibFreeImage.getBPP @native
  end

  def finalize
    unless @native.null?
      LibFreeImage.unload(@native)
      @native = Pointer(Void*).null.as(LibFreeImage::FIBITMAP*)
    end
  end

  def size
    Vector2u.new(@width, @height)
  end

  def byte_size
    LibFreeImage.getLine @native
  end

  def clone
    Image.new LibFreeImage.clone @native
  end

  def pixels : Bytes
    ptr = LibFreeImage.getBits @native
    Bytes.new ptr, byte_size
  end

  protected def initialize(@native : LibFreeImage::FIBITMAP*)
    @width = LibFreeImage.getWidth @native
    @height = LibFreeImage.getHeight @native
    @bpp = LibFreeImage.getBPP @native
  end
end

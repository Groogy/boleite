class Boleite::Private::OpenGLTexture < Boleite::Texture
  include CrystalClear
  
  @@internal_formats = {
    {Format::Red, Type::Integer8} => LibGL::R8, {Format::Red, Type::Integer16} => LibGL::R16,
    {Format::Red, Type::Float16} => LibGL::R16F, {Format::Red, Type::Float32} => LibGL::R32F,
    {Format::RG, Type::Integer8} => LibGL::RG8, {Format::RG, Type::Integer16} => LibGL::RG16,
    {Format::RG, Type::Float16} => LibGL::RG16F, {Format::RG, Type::Float32} => LibGL::RG32F,
    {Format::RGB, Type::Integer8} => LibGL::RGB8, {Format::RGB, Type::Integer16} => LibGL::RGB16,
    {Format::RGB, Type::Float16} => LibGL::RGB16F, {Format::RGB, Type::Float32} => LibGL::RGB32F,
    {Format::RGBA, Type::Integer8} => LibGL::RGBA8, {Format::RGBA, Type::Integer16} => LibGL::RGBA16,
    {Format::RGBA, Type::Float16} => LibGL::RGBA16F, {Format::RGBA, Type::Float32} => LibGL::RGBA32F,
  }
  
  @size = Vector2u.zero
  @depth = false
  @smooth = true
  @repeating = false
  @object_id : LibGL::UInt = 0u32

  def self.translate_format(format, type)
    @@internal_formats[{format, type}]
  end

  def self.translate_external_format(format)
    case format
    when Format::Red; LibGL::RED
    when Format::RG; LibGL::RG
    when Format::RGB; LibGL::RGB
    when Format::RGBA; LibGL::RGBA
    else
      raise ArgumentError.new "Invalid external data format given!(#{format})"
    end
  end

  def self.translate_unpack_alignment(format)
    case format
    when Format::RGBA; 4
    when Format::RGB; 3
    when Format::RG; 2
    else; 1
    end
  end

  def self.maximum_size : UInt32
    size = 0
    GL.safe_call { LibGL.getIntegerv LibGL::MAX_TEXTURE_SIZE, pointerof(size) }
    size.to_u
  end

  def initialize
    GL.safe_call { LibGL.genTextures 1, pointerof(@object_id) }
    @format = Format::Red
    @type   = Type::Integer8
  end

  def finalize
    GL.safe_call { LibGL.deleteTextures 1, pointerof(@object_id) }
  end

  def create(width : UInt32, height : UInt32, @format : Format, @type : Type) : Void
    @size = Vector2u.new(width, height)
    @depth = false

    internal_format = self.class.translate_format(format, type)
    create_internal width, height, internal_format
  end

  def create_depth(width : UInt32, height : UInt32) : Void
    @size = Vector2u.new(width, height)
    @format = Format::Red
    @type = Format::Float32
    @depth = true
    create_internal width, height LibGL::DEPTH_COMPONENT
  end

  def create_internal(width, height, format)
    activate do
      GL.safe_call do
        LibGL.texImage2D LibGL::TEXTURE_2D, 0, format, width, height, 0, LibGL::RGBA, LibGL::UNSIGNED_BYTE, nil
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, @repeating ? LibGL::REPEAT : LibGL::CLAMP
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, @repeating ? LibGL::REPEAT : LibGL::CLAMP
      end
    end
  end

  requires x_dest + width <= @size.x
  requires y_dest + height <= @size.y
  requires @depth == false
  def update(pixels : Pointer(UInt8), width, height, x_dest, y_dest, format : Format)
    activate do
      GL.safe_call do
        external_format = self.class.translate_external_format format
        alignment = self.class.translate_unpack_alignment @format
        LibGL.pixelStorei LibGL::UNPACK_ALIGNMENT, alignment
        LibGL.texSubImage2D LibGL::TEXTURE_2D, 0, x_dest, y_dest, width, height, external_format, LibGL::UNSIGNED_BYTE, pixels
        LibGL.pixelStorei LibGL::UNPACK_ALIGNMENT, 4
      end
    end
  end

  requires x_dest + width <= @size.x
  requires y_dest + height <= @size.y
  requires @depth == false
  def update(pixels : Pointer(Float32), width, height, x_dest, y_dest, format : Format)
    activate do
      GL.safe_call do
        external_format = self.class.translate_external_format format
        alignment = self.class.translate_unpack_alignment @format
        LibGL.pixelStorei LibGL::UNPACK_ALIGNMENT, alignment
        LibGL.texSubImage2D LibGL::TEXTURE_2D, 0, x_dest, y_dest, width, height, external_format, LibGL::FLOAT, pixels
        LibGL.pixelStorei LibGL::UNPACK_ALIGNMENT, 4
      end
    end
  end


  requires x + texture.size.x <= @size.x
  requires y + texture.size.y <= @size.y
  def update(texture, x, y)
    src_fb = OpenGLFrameBuffer.new
    dst_fb = OpenGLFrameBuffer.new
    tex_size = texture.size.to_i

    src_fb.attach_buffer texture, :src, 0u8
    dst_fb.attach_buffer self, :src, 0u8
    dst_fb.blit src_fb, IntRect.new(0, 0, tex_size.x, tex_size.y), IntRect.new(x, y, x + tex_size.x, y + tex_size.y)
  end

  def size : Vector2u
    @size
  end

  def format : Format
    @format
  end

  def type : Type
    @type
  end

  def is_depth? : Bool
    @depth
  end

  def is_smooth? : Bool
    @smooth
  end

  def smooth=(val : Bool) : Bool
    @smooth = val
    activate do
      GL.safe_call do
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
      end
    end
    @smooth
  end

  def is_repeating? : Bool
    @repeating
  end
  
  def repeating=(val : Bool) : Bool
    @repeating = val
    activate do
      GL.safe_call do
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, @repeating ? LibGL::REPEAT : LibGL::CLAMP
        LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, @repeating ? LibGL::REPEAT : LibGL::CLAMP
      end
    end
    @repeating
  end

  def activate(&block)
    GL.safe_call { LibGL.bindTexture LibGL::TEXTURE_2D, @object_id }
    result = yield
    GL.safe_call { LibGL.bindTexture LibGL::TEXTURE_2D, 0 }
    result
  end

  def bind
    GL.safe_call { LibGL.bindTexture LibGL::TEXTURE_2D, @object_id }
  end

  def identifier
    @object_id
  end
end

module Boleite
  module Private
    class GLFWOpenGLTexture < Texture
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
      @object_id : LibGL::UInt = 0u32

      def self.translate_format(format, type)
        @@internal_formats[{format, type}]
      end

      def self.translate_bpp(bpp)
        case bpp
        when 8; LibGL::RED
        when 16; LibGL::RG
        when 24; LibGL::RGB
        when 32; LibGL::RGBA
        else
          raise ArgumentError.new "Invalid bits per pixel format given!(#{bpp})"
        end
      end

      def initialize
        GL.safe_call { LibGL.genTextures 1, pointerof(@object_id) }
      end

      def finalize
        GL.safe_call { LibGL.deleteTextures 1, pointerof(@object_id) }
      end

      def create(width : UInt32, height : UInt32, format : Format, type : Type) : Void
        @size = Vector2u.new(width, height)
        @depth = false

        internal_format = self.class.translate_format(format, type)
        create_internal width, height, internal_format
      end

      def create_depth(width : UInt32, height : UInt32) : Void
        @size = Vector2u.new(width, height)
        @depth = true
        create_internal width, height LibGL::DEPTH_COMPONENT
      end

      def create_internal(width, height, format)
        activate do
          GL.safe_call do
            LibGL.texImage2D LibGL::TEXTURE_2D, 0, format, width, height, 0, LibGL::RGBA, LibGL::UNSIGNED_BYTE, nil
            LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
            LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
          end
        end
      end
  
      requires(update(pixels, width, height, x_dest, y_dest, bpp), x_dest + width <= @size.x)
      requires(update(pixels, width, height, x_dest, y_dest, bpp), y_dest + height <= @size.y)
      requires(update(pixels, width, height, x_dest, y_dest, bpp), @depth == false)
      def update(pixels, width, height, x_dest, y_dest, bpp)
        activate do
          GL.safe_call do
            external_format = self.class.translate_bpp(bpp)
            LibGL.texSubImage2D LibGL::TEXTURE_2D, 0, x_dest, y_dest, width, height, external_format, LibGL::UNSIGNED_BYTE, pixels
          end
        end
      end

      def size : Vector2u
        @size
      end

      def is_depth? : Boolean
        @depth
      end

      def is_smooth? : Boolean
        @smooth
      end

      def smooth=(val : Boolean) : Boolean
        @smooth = val
        activate do
          GL.safe_call do
            LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
            LibGL.texParameteri LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, @smooth ? LibGL::LINEAR : LibGL::NEAREST
          end
        end
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
    end
  end
end
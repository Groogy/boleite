abstract class Boleite::RenderTarget
end

class Boleite::Private::GLFWSurface < Boleite::RenderTarget
  def initialize(@surface : LibGLFW3::Window)
  end

  def finalize()
    unless @surface.null?
      GLFW.safe_call do
        LibGLFW3.destroyWindow(@surface)
      end
      @surface = Pointer(Void).null.as(LibGLFW3::Window)
    end
  end

  def width : UInt32
    size.x
  end

  def height : UInt32
    size.y
  end

  def size : Boleite::Vector2u
    GLFW.safe_call do
      LibGLFW3.getWindowSize @surface, out width, out height
      Vector2u.new width.to_u32, height.to_u32
    end
  end

  def ptr
    @surface
  end
end

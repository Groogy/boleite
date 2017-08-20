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

  def width
    size.x
  end

  def height
    size.y
  end

  def size
    GLFW.safe_call do
      LibGLFW3.getWindowSize @surface, out width, out height
      Vector2u.new width.to_u32, height.to_u32
    end
  end

  def ptr
    @surface
  end
end

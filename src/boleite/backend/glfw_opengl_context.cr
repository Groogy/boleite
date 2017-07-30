module Boleite
  abstract class GraphicsContext
  end

  module Private
    class GLFWOpenGLContext < GraphicsContext
      def initialize(@glfw_surface : GLFWSurface)
        GLFW.safe_call { LibGLFW3.makeContextCurrent(@glfw_surface.ptr) }
      end

      def main_target
        @glfw_surface
      end

      def clear(color)
        GLFW.safe_call { LibGL.clearColor(color.r, color.g, color.b, color.a) }
        GLFW.safe_call { LibGL.clear(LibGL::COLOR_BUFFER_BIT) }
      end

      def present
        GLFW.safe_call{ LibGLFW3.swapBuffers(@glfw_surface.ptr) }
      end
    end
  end
end
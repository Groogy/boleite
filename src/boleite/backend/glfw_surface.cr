module Boleite
  # Forward declaration
  class RenderTarget
  end

  module Private
    class GLFWSurface < RenderTarget
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

      def ptr
        @surface
      end
    end
  end
end
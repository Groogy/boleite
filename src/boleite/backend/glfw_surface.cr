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
          LibGLFW3.destroyWindow(@surface)
          @surface = Pointer(Void).null.as(LibGLFW3::Window)
        end
      end
    end
  end
end
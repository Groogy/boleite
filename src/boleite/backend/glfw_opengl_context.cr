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
        GL.safe_call { LibGL.clearColor(color.r, color.g, color.b, color.a) }
        GL.safe_call { LibGL.clear(LibGL::COLOR_BUFFER_BIT) }
      end

      def present
        GLFW.safe_call{ LibGLFW3.swapBuffers(@glfw_surface.ptr) }
      end

      def create_vertex_buffer_object : VertexBufferObject
        GLFWOpenGLVertexBufferObject.new
      end

      def create_shader(parser : ShaderParser) : Shader
        GLFWOpenGLShader.new(parser)
      end

      def create_texture : Texture
        GLFWOpenGLTexture.new
      end
    end
  end
end
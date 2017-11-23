abstract class Boleite::GraphicsContext
end

class Boleite::Private::GLFWOpenGLContext < Boleite::GraphicsContext
  def initialize(@glfw_surface : GLFWSurface)
    GLFW.safe_call { LibGLFW3.makeContextCurrent(@glfw_surface.ptr) }
    GLFW.safe_call { LibGLFW3.swapInterval 0 }
    GL.safe_call { LibGL.cullFace LibGL::BACK }
    GL.safe_call { LibGL.enable LibGL::CULL_FACE }
  end

  def main_target
    @glfw_surface
  end

  def clear(color)
    GL.safe_call { LibGL.clearColor(color.r, color.g, color.b, color.a) }
    GL.safe_call { LibGL.clear LibGL::COLOR_BUFFER_BIT }
  end

  def clear_depth
    GL.safe_call { LibGL.clear LibGL::DEPTH_BUFFER_BIT }
  end

  def scissor=(rect : IntRect) : Void
    GL.safe_call { LibGL.enable LibGL::SCISSOR_TEST }
    GL.safe_call { LibGL.scissor rect.left, rect.top, rect.width, rect.height }
  end

  def scissor=(arg : Nil) : Void
    GL.safe_call { LibGL.disable LibGL::SCISSOR_TEST }
  end

  def present
    GLFW.safe_call{ LibGLFW3.swapBuffers(@glfw_surface.ptr) }
  end

  def create_vertex_buffer_object : VertexBufferObject
    OpenGLVertexBufferObject.new
  end

  def create_vertex_buffer : VertexBuffer
    OpenGLVertexBuffer.new
  end

  def create_shader(parser : ShaderParser) : Shader
    OpenGLShader.new(parser)
  end

  def create_texture : Texture
    OpenGLTexture.new
  end

  def create_frame_buffer : FrameBuffer
    OpenGLFrameBuffer.new
  end

  def texture_maximum_size : UInt32
    OpenGLTexture.maximum_size
  end
end

abstract class Boleite::GraphicsContext
  abstract def main_target : RenderTarget
  abstract def clear(color : Colorf) : Void
  abstract def clear_depth() : Void
  abstract def present : Void

  abstract def scissor=(rect : IntRect) : Void
  abstract def scissor=(arg : Nil) : Void

  abstract def create_vertex_buffer_object : VertexBufferObject
  abstract def create_vertex_buffer : VertexBuffer
  abstract def create_shader(parser : ShaderParser) : Shader
  abstract def create_texture() : Texture
  abstract def create_frame_buffer() : FrameBuffer

  abstract def texture_maximum_size : UInt32
end

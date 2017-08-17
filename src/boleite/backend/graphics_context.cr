module Boelite
  abstract class GraphicsContext
    abstract def main_target : RenderTarget
    abstract def clear(color : Colorf) : Void
    abstract def present : Void

    abstract def create_vertex_buffer_object : VertexBufferObject
    abstract def create_shader(parser : ShaderParser) : Shader
  end
end
module Boleite
  abstract class FrameBuffer
    abstract def activate(&block)
    abstract def attach_buffer(texture : Texture, identifier : Symbol, slot : UInt8): Void
    abstract def attach_depth_buffer(texture : Texture) : Void
    abstract def detach_buffer(identifier : Symbol) : Void
    abstract def detach_depth_buffer() : Void
    abstract def detach_all_buffers() : Void
  end
end
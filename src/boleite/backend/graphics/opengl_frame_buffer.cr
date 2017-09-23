class Boleite::Private::OpenGLFrameBuffer < Boleite::FrameBuffer
  struct AttachmentData
    getter texture, slot

    def initialize(@texture : OpenGLTexture, @slot : UInt8)
    end
  end
  
  @object_id : LibGL::UInt = 0u32
  @attachments = {} of Symbol => AttachmentData
  @depth_texture : OpenGLTexture? = nil
  
  def initialize
    GL.safe_call { LibGL.genFramebuffers 1, pointerof(@object_id) }
  end

  def finalize
    GL.safe_call { LibGL.deleteFramebuffers 1, pointerof(@object_id) }
  end

  def activate(&block)
    activate LibGL::FRAMEBUFFER, &block
  end

  def activate(target, &block)
    GL.safe_call { LibGL.bindFramebuffer target, @object_id }
    result = yield
    GL.safe_call { LibGL.bindFramebuffer target, 0 }
    result
  end

  def blit(src, src_rect, dst_rect)
    activate(LibGL::DRAW_FRAMEBUFFER) do
      src.activate(LibGL::READ_FRAMEBUFFER) do
        src1, src2 = src_rect.bounds
        dst1, dst2 = dst_rect.bounds
        GL.safe_call { LibGL.blitFramebuffer src1.x, src1.y, src2.x, src2.y, dst1.x, dst1.y, dst2.x, dst2.y, LibGL::COLOR_BUFFER_BIT, LibGL::NEAREST }
      end
    end
  end
  
  def attach_buffer(texture : Texture, identifier : Symbol, slot : UInt8)
    activate do
      tex = texture.as(OpenGLTexture)
      GL.safe_call { LibGL.framebufferTexture2D LibGL::FRAMEBUFFER, LibGL::COLOR_ATTACHMENT0 + slot, LibGL::TEXTURE_2D, tex.identifier, 0 }
      @attachments[identifier] = AttachmentData.new tex, slot
    end
  end

  requires(attach_depth_buffer(texture), texture.is_depth?)
  def attach_depth_buffer(texture)
    activate do
      tex = texture.as(OpenGLTexture)
      GL.safe_call { LibGL.framebufferTexture2D LibGL::FRAMEBUFFER, LibGL::DEPTH_ATTACHMENT, LibGL::TEXTURE_2D, tex.identifier, 0 }
      @depth_texture = tex
    end
  end

  def detach_buffer(identifier)
    activate do
      attachment = @attachments[identifier]
      GL.safe_call { LibGL.framebufferTexture2D Lib::FRAMEBUFFER, LibGL::COLOR_ATTACHMENT0 + attachment.slot, LibGL::TEXTURE_2D, 0, 0 }
      @attachments.delete identifier
    end
  end

  def detach_depth_buffer()
    activate do
      GL.safe_call { LibGL.framebufferTexture2D Lib::FRAMEBUFFER, LibGL::DEPTH_ATTACHMENT, LibGL::TEXTURE_2D, 0, 0 }
      @depth_texture = nil
    end
  end

  def detach_all_buffers()
    activate do
      @attachments.size.times do |index|
        GL.safe_call { LibGL.framebufferTexture2D Lib::FRAMEBUFFER, LibGL::COLOR_ATTACHMENT0 + index, LibGL::TEXTURE_2D, 0, 0 }
      end
      GL.safe_call { LibGL.framebufferTexture2D Lib::FRAMEBUFFER, LibGL::DEPTH_ATTACHMENT, LibGL::TEXTURE_2D, 0, 0 }
      @depth_texture = nil
      @attachments.clear
    end
  end
end
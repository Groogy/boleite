class Boleite::Private::OpenGLFrameBuffer < Boleite::FrameBuffer
  struct AttachmentData
    getter texture, slot

    def initialize(@texture, @slot)
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
    GL.safe_call { LibGL.bindFramebuffer LibGL::FRAMEBUFFER, @object_id }
    result = yield
    GL.safe_call { LibGL.bindFramebuffer LibGL::FRAMEBUFFER, 0 }
    result
  end
  
  def attach_buffer(texture, identifier, slot)
    activate do
      tex = texture.as(OpenGLTexture)
      GL.safe_call { LibGL.framebufferTexture2D LibGL::FRAMEBUFFER, LibGL::COLOR_ATTACHMENT0 + slot, LibGL::TEXTURE_2D, tex.identifier, 0 }
      @attachments[identifer] = AttachmentData.new tex, slot
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
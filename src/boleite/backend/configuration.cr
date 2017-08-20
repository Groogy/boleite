class Boleite::BackendConfiguration
  enum GfxType
    OpenGL
    Vulkan # Not supported
  end
  
  property :gfx
  property :version
  property :video_mode
  property :double_buffering
  property :multisamples

  @gfx = GfxType::OpenGL
  @version = Version.new(4, 5)
  @video_mode = VideoMode.new
  @double_buffering = true
  @multisamples = 2_u8

  def initialize()
  end
end

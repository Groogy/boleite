module Boleite
  class BackendConfiguration
    enum GfxType
      OpenGL
      Vulkan # Not supported
    end
    
    property :gfx
    property :version
    property :video_mode

    @gfx = GfxType::OpenGL
    @version = Version.new(4, 5)
    @video_mode = VideoMode.new

    def initialize()
    end
  end
end
class Boleite::Private::GLFWMonitor
  def initialize(@ptr : LibGLFW3::Monitor)
  end

  def current_video_mode
    LibGLFW3.getVideoMode(@ptr).value
  end

  def ptr
    @ptr
  end
end

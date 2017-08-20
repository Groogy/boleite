class Boleite:: BackendException < Exception
end

abstract class Boleite::Backend
  def self.create_glfw()
    Private::GLFW.new
  end

  abstract def create_graphics(config : BackendConfiguration) : GraphicsContext
  abstract def default_config : BackendConfiguration
  abstract def poll_event : InputEvent | Nil
end

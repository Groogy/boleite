module Boleite
  class BackendException < Exception
  end
  
  abstract class Backend
    def self.create_glfw()
      Private::GLFW.new
    end

    abstract def create_main_target(config : BackendConfiguration) : RenderTarget
    abstract def default_config : BackendConfiguration
    abstract def poll_event : InputEvent | Nil
  end
end
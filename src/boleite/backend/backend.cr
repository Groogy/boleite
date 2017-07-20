module Boleite
  class BackendException < Exception
  end
  
  abstract class Backend
    def self.create_glfw()
      Private::GLFWBackend.new
    end

    abstract def default_config : BackendConfiguration
  end
end
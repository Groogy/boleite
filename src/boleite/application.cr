module Boleite
  abstract class Configuration
    abstract def backend : BackendConfiguration
  end

  abstract class Application
    getter :configuration

    @backend : Backend
    @configuration : Configuration
    @render_target : RenderTarget

    def initialize
      @backend = Backend.create_glfw
      @configuration = create_configuration
      @render_target = @backend.create_main_target(@configuration.backend)

    end

    abstract def create_configuration : Configuration
  end
end
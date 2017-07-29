module Boleite
  abstract class Configuration
    abstract def backend : BackendConfiguration
  end

  abstract class Application
    class InputHandler < InputReceiver
      def initialize()
      end

      def bind(app)
        register ClosedAction, ->app.close
      end
    end

    getter :configuration

    @backend : Backend
    @configuration : Configuration
    @render_target : RenderTarget
    @input_handler = InputHandler.new
    @input_router = InputRouter.new
    @running = true

    def initialize
      @backend = Backend.create_glfw
      @configuration = create_configuration
      @render_target = @backend.create_main_target(@configuration.backend)
      @input_handler.bind(self)
      @input_router.register(@input_handler)
    end

    def run
      while @running
        while event = @backend.poll_event
          @input_router.process event
        end
      end
    end

    def close
      @running = false
    end

    abstract def create_configuration : Configuration
  end
end
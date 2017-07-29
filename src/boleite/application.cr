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
    getter :input_router
    getter :state_stack

    @backend : Backend
    @configuration : Configuration
    @graphics : GraphicsContext
    @input_handler = InputHandler.new
    @input_router = InputRouter.new
    @state_stack = StateStack.new
    @running = true

    def initialize
      @backend = Backend.create_glfw
      @configuration = create_configuration
      @graphics = @backend.create_graphics(@configuration.backend)
      @input_handler.bind(self)
      @input_router.register(@input_handler)
    end

    def run
      while @running
        while event = @backend.poll_event
          @input_router.process event
        end

        @graphics.clear Color.black
        top_state = @state_stack.top
        top_state.update
        top_state.render
        @graphics.present
      end
    end

    def close
      @running = false
    end

    abstract def create_configuration : Configuration
  end
end
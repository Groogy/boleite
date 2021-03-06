abstract class Boleite::Configuration
  abstract def backend : BackendConfiguration
end

abstract class Boleite::Application
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
  getter :graphics

  @backend : Backend
  @configuration : Configuration
  @graphics : GraphicsContext
  @input_handler = InputHandler.new
  @input_router = InputRouter.new
  @state_stack = StateStack.new
  @clock = Clock.new
  @running = true

  def initialize
    @backend = Backend.create_glfw
    @configuration = create_configuration
    @graphics = @backend.create_graphics(@configuration.backend)
    @input_handler.bind(self)
    @input_router.register(@input_handler)
  end

  def run
    @clock.restart
    while @running
      tick_time = @clock.restart
      top_state = @state_stack.top
      process_events
      process_state top_state, tick_time
    end
  end

  def close
    @running = false
  end

  abstract def create_configuration : Configuration

  private def process_events
    while event = @backend.poll_event
      @input_router.process event
    end
  end

  private def process_state(state, delta)
    state.update(delta)
    state.render(delta)
  end
end

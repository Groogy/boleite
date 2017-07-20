module Boleite
  abstract class Configuration
  end

  abstract class Application
    getter :configuration

    @backend : Backend
    @configuration : Configuration

    def initialize
      @backend = Backend.create_glfw
      @configuration = create_configuration
    end

    abstract def create_configuration : Configuration
  end
end
module Boleite
  abstract class Configuration
  end

  abstract class Application
    getter :configuration

    @configuration : Configuration

    def initialize
      @configuration = create_configuration
    end

    abstract def create_configuration : Configuration
  end
end
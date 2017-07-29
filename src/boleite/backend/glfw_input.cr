module Boleite
  module Private
    module GLFWInput
      @@events = [] of InputEvent
      @@iterator = 0

      def self.update
        if @@iterator >= @@events.size
          @@events.clear
          @@iterator = 0
          LibGLFW3.pollEvents
        end
      end

      def self.poll : InputEvent | Nil
        self.update
        if @@iterator < @@events.size
          event = @@events[@@iterator]
          @@iterator += 1
          event
        else
          nil
        end
      end

      def self.bind_callbacks(window)
        puts "oi"
        LibGLFW3.setWindowCloseCallback(window, ->self.on_window_close)
      end

      def self.on_window_close(window)
        puts "aw yiz"
        @@events << ClosedEvent.new
      end
    end
  end
end
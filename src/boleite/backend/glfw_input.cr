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
        LibGLFW3.setWindowCloseCallback(window, ->self.on_window_close)
        LibGLFW3.setKeyCallback(window, ->self.on_key)
        LibGLFW3.setCharCallback(window, ->self.on_char)
        LibGLFW3.setMouseButtonCallback(window, ->self.on_mouse_button)
        LibGLFW3.setScrollCallback(window, ->self.on_scroll)
        LibGLFW3.setCursorPosCallback(window, ->self.on_cursor_pos)
      end

      def self.on_window_close(window)
        @@events << ClosedEvent.new
      end

      def self.on_key(window, key, scancode, action, mods)
        key = translate_key key
        action = translate_action action
        mods = translate_mods mods
        @@events << KeyEvent.new key, action, mods
      end

      def self.on_char(window, key)
        @@events << CharEvent.new key
      end

      def self.on_mouse_button(window, button, action, mods)
        button = translate_mouse_button button
        action = translate_action action
        mods = translate_mods mods
        @@events << MouseButtonEvent.new button, action, mods
      end

      def self.on_scroll(window, x_scroll, y_scroll)
        @@events << MouseScrollEvent.new x_scroll, y_scroll
      end

      def self.on_cursor_pos(window, x_pos, y_pos)
        @@events << MousePosEvent.new x_pos, y_pos
      end
    end
  end
end
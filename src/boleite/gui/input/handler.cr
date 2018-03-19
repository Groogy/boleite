class Boleite::GUI
  class InputHandler < InputReceiver
    @widget = WeakRef(Widget | Nil).new nil

    def widget=(widget)
      @widget = WeakRef(Widget).new widget
    end

    def widget
      if widget = @widget.try(&.value)
        widget
      else
        nil
      end
    end

    def process(event : InputEvent)
      if widget = self.widget
        super(event) if widget.visible? && widget.enabled?
      end
    end
  end
end
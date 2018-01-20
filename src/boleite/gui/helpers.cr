# This file needs to be read first!
class Boleite::GUI
  abstract class Widget
    macro setter_state(*args)
      {% for name in args %}
        def {{name}}=(@{{name}})
          state_change.emit
        end
      {% end %}
    end
  end
end
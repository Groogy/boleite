abstract class Boleite::InputEvent
end

class Boleite::ClosedEvent < Boleite::InputEvent
end

class Boleite::KeyEvent < Boleite::InputEvent
  getter key, action, mods

  def initialize(@key : Key, @action : InputAction, @mods : KeyMod)
  end
end

class Boleite::CharEvent < Boleite::InputEvent
  getter :char

  def initialize(@char : UInt32)
  end
end

class Boleite::MouseButtonEvent < Boleite::InputEvent
  getter :button, action, mods

  def initialize(@button : Mouse, @action : InputAction, @mods : KeyMod)
  end
end

class Boleite::MouseScrollEvent < Boleite::InputEvent
  getter :x_scroll, :y_scroll

  def scroll
    Vector2f.new(@x_scroll, @y_scroll)
  end

  def initialize(@x_scroll : Float64, @y_scroll : Float64)
  end
end

class Boleite::MousePosEvent < Boleite::InputEvent
  getter :x, :y

  def pos
    Vector2f.new(@x, @y)
  end

  def initialize(@x : Float64, @y : Float64)
  end
end

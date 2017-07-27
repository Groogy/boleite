module Boleite
  abstract class InputEvent
  end

  class ClosedEvent < InputEvent
  end

  class KeyEvent < InputEvent
    enum Action
      Press
      Release
      Repeat
    end

    getter key, action, mods

    def initialize(@key : Key, @action : Action, @mods : KeyMod)
    end
  end
end
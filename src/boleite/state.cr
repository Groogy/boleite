module Boleite
  abstract class State
    @state : State | Nil

    def initialize
      @state = nil
    end

    def next
      @state
    end

    def next=(@next : State | Nil)
    end

    def enable
    end

    def disable
    end

    abstract def update(delta)
    abstract def render(delta)
  end
end
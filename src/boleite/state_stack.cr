module Boleite
  class StateStack
    def initialize
      @state = nil
    end

    def empty?
      @state.nil?
    end

    requires(push(state : State), state.nil? == false)
    def push(state : State)
      state.next = @state
      @state = state
      state.enable
    end

    requires(pop, empty? == false)
    def pop
      old_state = @state.as(State)
      @state = old_state.next
      old_state.next = nil
      old_state.disable
      old_state
    end

    def clear
      while !empty?
        pop
      end
    end

    requires(top, empty? == false)
    def top
      @state.as(State)
    end
  end
end
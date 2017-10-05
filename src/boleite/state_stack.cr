class Boleite::StateStack
  include CrystalClear
  
  def initialize
    @state = nil
  end

  def empty?
    @state.nil?
  end

  requires state.nil? == false
  def push(state : State)
    state.next = @state
    @state = state
    state.enable
  end

  requires empty? == false
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

  requires empty? == false
  def top
    @state.as(State)
  end
end

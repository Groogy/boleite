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
    if prev_state = @state
      prev_state.disable
    end
    @state = state
    state.enable
  end

  requires empty? == false
  def pop
    old_state = @state.as(State)
    @state = old_state.next
    old_state.next = nil
    old_state.disable
    if new_state = @state
      new_state.enable
    end
    old_state
  end

  requires empty? == false
  requires state.nil? == false
  def replace(state : State)
    pop
    push state
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

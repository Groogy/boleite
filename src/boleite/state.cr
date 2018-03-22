abstract class Boleite::State
  @next : State | Nil

  def initialize
    @next = nil
  end

  def next
    @next
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

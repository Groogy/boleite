class Boleite::InputRouter
  @receivers = [] of InputReceiver

  def initialize()
  end

  requires(register(receiver), @receivers.includes?(receiver) == false)
  def register(receiver)
    @receivers << receiver
  end

  def unregister(receiver)
    @receivers.remove(receiver)
  end

  def process(event : InputEvent)
    @receivers.each &.process(event)
  end
end

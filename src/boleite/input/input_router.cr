class Boleite::InputRouter
  include CrystalClear
  
  @receivers = [] of InputReceiver

  def initialize()
  end

  requires @receivers.includes?(receiver) == false
  def register(receiver)
    @receivers << receiver
  end

  def unregister(receiver)
    @receivers.remove(receiver)
  end

  def process(event : InputEvent)
    @receivers.each do |receiver|
      receiver.process(event) unless event.claimed?
    end
  end
end

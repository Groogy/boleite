class Boleite::InputRouter < Boleite::InputProcessor
  include CrystalClear
  
  @receivers = [] of InputProcessor

  def initialize()
  end

  requires @receivers.includes?(receiver) == false
  requires receiver != self
  def register(receiver)
    @receivers << receiver
  end

  requires @receivers.includes?(receiver) == false
  requires receiver != self
  def register_at(index, receiver)
    @receivers.insert index, receiver
  end

  def unregister(receiver)
    obj = @receivers.delete receiver
  end

  def process(event : Boleite::InputEvent) : Void
    @receivers.each do |receiver|
      receiver.process event
    end
  end
end

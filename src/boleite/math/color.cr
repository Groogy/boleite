module Boleite::Color
  def self.red
    Colorf.new 1.0_f32, 0.0_f32, 0.0_f32, 1.0_f32
  end

  def self.green
    Colorf.new 0.0_f32, 1.0_f32, 0.0_f32, 1.0_f32
  end

  def self.blue
    Colorf.new 0.0_f32, 0.0_f32, 1.0_f32, 1.0_f32
  end

  def self.black
    Colorf.new 0.0_f32, 0.0_f32, 0.0_f32, 1.0_f32
  end

  def self.white
    Colorf.new 1.0_f32, 1.0_f32, 1.0_f32, 1.0_f32
  end

  def self.yellow
    Colorf.new 1f32, 1f32, 0f32, 1f32
  end
end

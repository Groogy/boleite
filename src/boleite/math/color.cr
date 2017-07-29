module Boleite
  module Color
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
  end
end
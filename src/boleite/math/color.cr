module Boleite
  module Color
    def self.red
      Colorf.new(1.0, 0.0, 0.0, 1.0)
    end

    def self.green
      Colorf.new(0.0, 1.0, 0.0, 1.0)
    end

    def self.blue
      Colorf.new(0.0, 0.0, 1.0, 1.0)
    end
  end
end
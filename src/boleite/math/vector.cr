module Boleite
  module Vector
    def self.clamp(value : VectorImp(T, N), min : VectorImp(T, N), max : VectorImp(T, N)) forall T, N
      left.class.new do |index|
        value[index].clamp min[index], max[index]
      end
    end

    def self.min(left : VectorImp(T, N), right : VectorImp(T, N)) forall T, N
      left.class.new do |index|
        Math.min left[index], right[index]
      end
    end

    def self.max(left : VectorImp(T, N), right : VectorImp(T, N)) forall T, N
      left.class.new do |index|
        Math.max left[index], right[index]
      end
    end

    def self.magnitude(value : VectorImp(T, N)) forall T, N
      Math.sqrt self.square_magnitude(value)
    end

    def self.square_magnitude(value : VectorImp(T, N)) forall T, N
      value.sum { |val| val * val }
    end

    def self.normalize(value : VectorImp(T, N)) forall T, N
      magnitude = self.magnitude(value)
      value.class.new do |index|
        value[index] / magnitude
      end
    end

    def self.dot(left : VectorImp(T, N), right : VectorImp(T, N)) forall T, N
      dot = T.zero
      N.times { |index| dot += left[index] * right[index] }
      dot
    end

    def self.cross(left : VectorImp(T, 3), right : VectorImp(T, 3)) forall T
      VectorImp(T, 3).new(
        left.y * right.z - left.z * right.y,
        left.z * right.x - left.x * right.z,
        left.x * right.y - left.y * right.x
      )
    end
  end
end

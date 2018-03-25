module Boleite::Vector
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

  def self.distance_to_ray(origin : VectorImp(T, 3), dir : VectorImp(T, 3), point : VectorImp(T, 3)) forall T
    cross = self.cross dir, point - origin
    self.magnitude cross
  end

  def self.closest_point_on_segment(a : VectorImp(T, 3), b : VectorImp(T, 3), point : VectorImp(T, 3), clamp = true) forall T
    ap = point - a
    ab = b - a
    ab2 = square_magnitude ab
    ap_ab = dot ap, ab
    t = ap_ab / ab2
    if clamp
      t = T.zero if t < 0
      t = T.new 1 if t > 1
    end
    a + ab * t
  end

  def self.distance_to_segment(a : VectorImp(T, 3), b : VectorImp(T, 3), point : VectorImp(T, 3), clamp = true) forall T
    closest = closest_point_on_segment a, b, point, clamp
    magnitude closest - point
  end
end

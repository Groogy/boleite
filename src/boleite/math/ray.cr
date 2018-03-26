class Boleite::Ray(T)
  @origin : VectorImp(T, 3)
  @direction : VectorImp(T, 3)

  getter origin, direction

  def self.new_from_points(near : VectorImp(T, 3), far : VectorImp(T, 3))
    self.new near, Vector.normalize far - near
  end

  def initialize(@origin : VectorImp(T, 3), @direction : VectorImp(T, 3))
  end
end
module Boleite::Matrix
  def self.mul(left : MatrixImp(T, 3, 9), right : MatrixImp(T, 3, 9)) forall T
    tmp = MatrixImp(T, 3, 9).new
    3.times do |x|
      ax1 = left[x, 0]
      ax2 = left[x, 1]
      ax3 = left[x, 2]
      3.times do |y|
        b1y = right[0, y]
        b2y = right[1, y]
        b3y = right[2, y]
        tmp[x, y] = ax1*b1y + ax2*b2y + ax3*b3y
      end
    end
    tmp
  end

  def self.mul(left : MatrixImp(T, 4, 16), right : MatrixImp(T, 4, 16)) forall T
    tmp = MatrixImp(T, 4, 16).new
    4.times do |x|
      ax1 = left[x, 0]
      ax2 = left[x, 1]
      ax3 = left[x, 2]
      ax4 = left[x, 3]
      4.times do |y|
        b1y = right[0, y]
        b2y = right[1, y]
        b3y = right[2, y]
        b4y = right[3, y]
        tmp[x, y] = ax1*b1y + ax2*b2y + ax3*b3y + ax4*b4y
      end
    end
    tmp
  end

  def self.translate(matrix : MatrixImp(T, 4, 16), translation : VectorImp(T, 3)) forall T
    cpy = matrix.dup
    cpy[3, 0] += translation.x
    cpy[3, 1] += translation.y
    cpy[3, 2] += translation.z
    cpy
  end

  def self.scale(matrix : MatrixImp(T, 3, 9), scale : VectorImp(T, 3)) forall T
    cpy = matrix.dup
    cpy[0, 0] *= scale.x
    cpy[1, 1] *= scale.y
    cpy[2, 2] *= scale.z
    cpy
  end

  def self.scale(matrix : MatrixImp(T, 4, 16), scale : VectorImp(T, 4)) forall T
    cpy = matrix.dup
    cpy[0, 0] *= scale.x
    cpy[1, 1] *= scale.y
    cpy[2, 2] *= scale.z
    cpy[3, 3] *= scale.w
    cpy
  end
  
  def self.inverse(matrix : MatrixImp(T, 3, 9)) forall T
    det = matrix[0, 0] * (matrix[1, 1] * matrix[2, 2] - matrix[2, 1] * matrix[1, 2]) -
      matrix[0, 1] * (matrix[1, 0] * matrix[2, 2] - matrix[1, 2] * matrix[2, 0]) +
      matrix[0, 2] * (matrix[1, 0] * matrix[2, 1] - matrix[1, 1] * matrix[2, 0])

    assert det != 0
    invdet = T.new(1) / det

    inv = MatrixImp(T, 3, 9).new
    inv[0, 0] = (matrix[1, 1] * matrix[2, 2] - matrix[2, 1] * matrix[1, 2]) * invdet
    inv[0, 1] = (matrix[0, 2] * matrix[2, 1] - matrix[0, 1] * matrix[2, 2]) * invdet
    inv[0, 2] = (matrix[0, 1] * matrix[1, 2] - matrix[0, 2] * matrix[1, 1]) * invdet
    inv[1, 0] = (matrix[1, 2] * matrix[2, 0] - matrix[1, 0] * matrix[2, 2]) * invdet
    inv[1, 1] = (matrix[0, 0] * matrix[2, 2] - matrix[0, 2] * matrix[2, 0]) * invdet
    inv[1, 2] = (matrix[1, 0] * matrix[0, 2] - matrix[0, 0] * matrix[1, 2]) * invdet
    inv[2, 0] = (matrix[1, 0] * matrix[2, 1] - matrix[2, 0] * matrix[1, 1]) * invdet
    inv[2, 1] = (matrix[2, 0] * matrix[0, 1] - matrix[0, 0] * matrix[2, 1]) * invdet
    inv[2, 2] = (matrix[0, 0] * matrix[1, 1] - matrix[1, 0] * matrix[0, 1]) * invdet
    return inv;
  end

  def self.inverse(matrix : MatrixImp(T, 4, 16)) forall T
    inv = MatrixImp(T, 4, 16).new
    inv[0] = matrix[5]  * matrix[10] * matrix[15] - matrix[5]  * matrix[11] * matrix[14] - 
            matrix[9]  * matrix[6]  * matrix[15] + matrix[9]  * matrix[7]  * matrix[14] +
            matrix[13] * matrix[6]  * matrix[11] - matrix[13] * matrix[7]  * matrix[10]

    inv[4] = -matrix[4]  * matrix[10] * matrix[15] + matrix[4]  * matrix[11] * matrix[14] + 
              matrix[8]  * matrix[6]  * matrix[15] - matrix[8]  * matrix[7]  * matrix[14] - 
              matrix[12] * matrix[6]  * matrix[11] + matrix[12] * matrix[7]  * matrix[10]

    inv[8] = matrix[4]  * matrix[9] * matrix[15] - matrix[4]  * matrix[11] * matrix[13] - 
            matrix[8]  * matrix[5] * matrix[15] + matrix[8]  * matrix[7]  * matrix[13] + 
            matrix[12] * matrix[5] * matrix[11] - matrix[12] * matrix[7]  * matrix[9]

    inv[12] = -matrix[4]  * matrix[9] * matrix[14] + matrix[4]  * matrix[10] * matrix[13] +
              matrix[8]  * matrix[5] * matrix[14] - matrix[8]  * matrix[6]  * matrix[13] - 
              matrix[12] * matrix[5] * matrix[10] + matrix[12] * matrix[6]  * matrix[9]

    inv[1] = -matrix[1]  * matrix[10] * matrix[15] + matrix[1]  * matrix[11] * matrix[14] + 
              matrix[9]  * matrix[2]  * matrix[15] - matrix[9]  * matrix[3]  * matrix[14] - 
              matrix[13] * matrix[2]  * matrix[11] + matrix[13] * matrix[3]  * matrix[10]

    inv[5] = matrix[0]  * matrix[10] * matrix[15] - matrix[0]  * matrix[11] * matrix[14] - 
            matrix[8]  * matrix[2]  * matrix[15] + matrix[8]  * matrix[3]  * matrix[14] + 
            matrix[12] * matrix[2]  * matrix[11] - matrix[12] * matrix[3]  * matrix[10]

    inv[9] = -matrix[0]  * matrix[9] * matrix[15] + matrix[0]  * matrix[11] * matrix[13] + 
              matrix[8]  * matrix[1] * matrix[15] - matrix[8]  * matrix[3]  * matrix[13] - 
              matrix[12] * matrix[1] * matrix[11] + matrix[12] * matrix[3]  * matrix[9]

    inv[13] = matrix[0]  * matrix[9] * matrix[14] - matrix[0]  * matrix[10] * matrix[13] - 
              matrix[8]  * matrix[1] * matrix[14] + matrix[8]  * matrix[2]  * matrix[13] + 
              matrix[12] * matrix[1] * matrix[10] - matrix[12] * matrix[2]  * matrix[9]

    inv[2] = matrix[1]  * matrix[6] * matrix[15] - matrix[1] * matrix[7] * matrix[14] - 
            matrix[5]  * matrix[2] * matrix[15] + matrix[5] * matrix[3] * matrix[14] + 
            matrix[13] * matrix[2] * matrix[7] - matrix[13] * matrix[3] * matrix[6]

    inv[6] = -matrix[0]  * matrix[6] * matrix[15] + matrix[0]  * matrix[7] * matrix[14] + 
              matrix[4]  * matrix[2] * matrix[15] - matrix[4]  * matrix[3] * matrix[14] - 
              matrix[12] * matrix[2] * matrix[7]  + matrix[12] * matrix[3] * matrix[6]

    inv[10] = matrix[0]  * matrix[5] * matrix[15] - matrix[0]  * matrix[7] * matrix[13] - 
              matrix[4]  * matrix[1] * matrix[15] + matrix[4]  * matrix[3] * matrix[13] + 
              matrix[12] * matrix[1] * matrix[7]  - matrix[12] * matrix[3] * matrix[5]

    inv[14] = -matrix[0]  * matrix[5] * matrix[14] + matrix[0]  * matrix[6] * matrix[13] + 
              matrix[4]  * matrix[1] * matrix[14] - matrix[4]  * matrix[2] * matrix[13] - 
              matrix[12] * matrix[1] * matrix[6]  + matrix[12] * matrix[2] * matrix[5]

    inv[3] = -matrix[1] * matrix[6] * matrix[11] + matrix[1] * matrix[7] * matrix[10] + 
              matrix[5] * matrix[2] * matrix[11] - matrix[5] * matrix[3] * matrix[10] - 
              matrix[9] * matrix[2] * matrix[7]  + matrix[9] * matrix[3] * matrix[6]

    inv[7] = matrix[0] * matrix[6] * matrix[11] - matrix[0] * matrix[7] * matrix[10] - 
            matrix[4] * matrix[2] * matrix[11] + matrix[4] * matrix[3] * matrix[10] + 
            matrix[8] * matrix[2] * matrix[7]  - matrix[8] * matrix[3] * matrix[6]

    inv[11] = -matrix[0] * matrix[5] * matrix[11] + matrix[0] * matrix[7] * matrix[9] + 
              matrix[4] * matrix[1] * matrix[11] - matrix[4] * matrix[3] * matrix[9] - 
              matrix[8] * matrix[1] * matrix[7]  + matrix[8] * matrix[3] * matrix[5]

    inv[15] = matrix[0] * matrix[5] * matrix[10] - matrix[0] * matrix[6] * matrix[9] - 
              matrix[4] * matrix[1] * matrix[10] + matrix[4] * matrix[2] * matrix[9] + 
              matrix[8] * matrix[1] * matrix[6]  - matrix[8] * matrix[2] * matrix[5]

    det = matrix[0] * inv[0] + matrix[1] * inv[4] + matrix[2] * inv[8] + matrix[3] * inv[12]

    assert det != 0
    det = T.new(1) / det
    MatrixImp(T, 4, 16).new do |index|
      inv[index] * det
    end
  end

  def self.calculate_fov_projection(fov : T, aspect : T, near : T, far : T, left_handed : Bool) forall T
    result = MatrixImp(T, 4, 16).identity
    one = T.new(1)
    half = T.new(0.5)
    frustrum_depth = far - near
    one_over_depth = one / frustrum_depth
    result[1, 1] = one / Math.tan(half * fov)
    result[0, 0] = (left_handed ? one : -one) * result[1, 1] / aspect
    result[2, 2] = far * one_over_depth
    result[3, 2] = (-far * near) * one_over_depth
    result[2, 3] = one
    result[3, 3] = T.new(0)
    result
  end

  def self.calculate_ortho_projection(left : T, right : T, top : T, bottom : T, near : T, far : T) forall T
    result = MatrixImp(T, 4, 16).identity
    two = T.new(2)
    one = T.new(1)
    result[0, 0] = two / (right - left)
    result[1, 1] = two / (top - bottom)
    result[2, 2] = -two / (far - near)
    result[3, 0] = -(right + left)/(right - left)
    result[3, 1] = -(top + bottom)/(top - bottom)
    result[3, 2] = -(far + near)/(far - near)
    result[3, 3] = one
    result
  end
end

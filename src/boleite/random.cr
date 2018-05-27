abstract class Boleite::Random
  include CrystalClear

  @seed : UInt32

  getter seed

  def initialize(@seed)
  end

  def get_int : UInt32
    generate
  end

  ensures return_value >= min
  ensures return_value < max
  def get_int(min, max) : UInt32
    num = generate
    num % (max - min) + min
  end

  def get_zero_to_one : Float64
    generate.to_f / UInt32::MAX
  end

  Contracts.ignore_method generate

  protected abstract def generate : UInt32
end

# Noise function based on Squirrel Eiserloh SquirrelNoise function from GDC17
class Boleite::NoiseRandom < Boleite::Random
  # These bit-noise been selected for having interesting/distinctive bits
  NOISE1 = 0xb5297a4d
  NOISE2 = 0x68e31da4
  NOISE3 = 0x1b56c4e9

  @index : UInt32

  getter index

  def initialize(seed, @index = 0u32)
    super(seed)
  end

  def generate : UInt32
    result = generate @index
    @index += 1
    result
  end

  def generate(num) : UInt32
    num *= NOISE1
    num += @seed
    num ^= num >> 8
    num += NOISE2
    num ^= num << 8
    num *= NOISE3
    num ^= num >> 8
    num
  end
end

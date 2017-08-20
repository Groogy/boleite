
struct Boleite::Version
  property :major
  property :minor
  property :patch

  def initialize()
    @major = 0_u8
    @minor = 0_u8
    @patch = 0_u8
  end

  def initialize(major : Int, minor : Int, patch : Int = 0_u8)
    @major = major.to_u8
    @minor = minor.to_u8
    @patch = patch.to_u8
  end

  def to_s(io)
    io << to_s
  end

  def to_s
    "#{@major}.#{@minor}.#{@patch}"
  end
end

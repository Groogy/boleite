class Boleite::Clock
  def initialize
    @start = Time.utc
  end

  def restart
    old = @start
    @start = Time.utc
    @start - old
  end

  def elapsed
    Time.utc_now - @start
  end
end

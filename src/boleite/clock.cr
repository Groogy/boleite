module Boleite
  class Clock
    def initialize
      @start = Time.utc_now
    end

    def restart
      old = @start
      @start = Time.utc_now
      @start - old
    end

    def elapsed
      Time.utc_now - @start
    end
  end
end
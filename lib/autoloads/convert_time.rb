class ConvertTime
  MINUTES_PER_HOUR = 60
  UNIT_MIN = 15

  class << self
    # "06:30" --> 390
    # "15:00" --> 900
    def to_min(time)
      time.split(":").map(&:to_i).inject { |hour, min| hour * 60 + min }
    end

    # 390 --> "06:30"
    def to_time(min)
      hour = two_digits(min / 60)
      minute = two_digits(min % 60)
      "#{hour}:#{minute}"
    end

    def total_units(start_min, end_min)
      (end_min - start_min) / UNIT_MIN
    end

    # 45(min) --> 3(units)
    def min_to_unit(min)
      min / UNIT_MIN
    end

    private

    def two_digits(num)
      num.to_s.rjust(2, "0")
    end
  end
end

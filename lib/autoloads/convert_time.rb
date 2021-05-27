class ConvertTime
  # "06:30" --> 390
  # "15:00" --> 900
  def self.to_min(time)
    time.split(":").map(&:to_i).inject { |hour, min| hour * 60 + min }
  end

  # 390 --> "06:30"
  def self.to_time(min)
    hour = two_digits(min / 60)
    minute = two_digits(min % 60)
    "#{hour}:#{minute}"
  end

  private

  def self.two_digits(num)
    num.to_s.rjust(2, "0")
  end
end

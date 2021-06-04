module PerUnitMin
  extend ActiveSupport::Concern

  def start_time
    start_min.present? ? ConvertTime.to_time(start_min) : nil
  end

  def end_time
    respond_to?(:end_min) && end_min.present? ? ConvertTime.to_time(end_min) : nil
  end

  def per_unit_start_min
    return if start_min.nil?
    unless start_min % Reservation::UNIT_MIN == 0
      errors.add(:start_min, Reservation::UNIT_MESSAGE)
    end
  end

  def per_unit_end_min
    return if end_min.nil?
    unless end_min % Reservation::UNIT_MIN == 0
      errors.add(:end_min, Reservation::UNIT_MESSAGE)
    end
  end

  def under_limit_unit
    return if start_min.nil? || end_min.nil?
    if ConvertTime.min_to_unit(end_min - start_min) < Reservation::LIMITE_UNITS
      errors.add(:start_min)
    end
  end
end

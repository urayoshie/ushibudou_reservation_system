module PerUnitMin
  extend ActiveSupport::Concern

  included do
    UNIT_MIN = ConvertTime::UNIT_MIN  # 15
    LIMITE_UNITS = 8
    LIMIT_MIN_RANGE = 0..1800

    def per_unit_start_min
      unless start_min % UNIT_MIN == 0
        errors.add(:start_min, UNIT_MESSAGE)
      end
    end

    def per_unit_end_min
      unless end_min % UNIT_MIN == 0
        errors.add(:start_min, UNIT_MESSAGE)
      end
    end
  end
end

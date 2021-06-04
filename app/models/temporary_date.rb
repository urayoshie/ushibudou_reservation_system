class TemporaryDate < ApplicationRecord
  include PerUnitMin

  validates :date, uniqueness: true

  validate :per_unit_start_min
  validate :per_unit_end_min
  validate :under_limit_unit

  class << self
    # start_date から end_date までの臨時休業日の配列を取得
    def closed_dates(start_date, end_date)
      where(date: start_date..end_date, start_min: nil).order(date: :asc).pluck(:date)
    end

    # start_date から end_date までの臨時営業日の配列を取得
    def business_dates(start_date, end_date)
      where(date: start_date..end_date).where.not(start_min: nil).order(date: :asc).pluck(:date)
      # temporary_dates = TemporaryDate.all.pluck(:date)
      # temporary_closed_dates = TemporaryDate.closed_dates(start_date, end_date)
      # temporary_business_dates = temporary_dates - temporary_closed_dates
    end
  end
end

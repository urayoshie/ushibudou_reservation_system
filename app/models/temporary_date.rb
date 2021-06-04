class TemporaryDate < ApplicationRecord
  include PerUnitMin

  validates :date, uniqueness: true

  validate :per_unit_start_min
  validate :per_unit_end_min
  validate :under_limit_unit
  validate :prevent_without_default
  validate :prevent_earlier_date

  PREVENT_WITHOUT_DEFAULT_MESSAGE = "は規定の営業・休業設定後でなければ登録できません"
  PREVENT_EARLIER_DATE_MESSAGE = "は初期設定より早い日付で登録できません"

  # 規定の営業・休業設定がなければ保存できないようにする
  def prevent_without_default
    unless DayCondition.exists?
      errors.add(:date, PREVENT_WITHOUT_DEFAULT_MESSAGE)
    end
  end

  # 初期設定より早い日付で登録できないようにする
  def prevent_earlier_date
    if date < DayCondition.initial_date
      errors.add(:date, PREVENT_EARLIER_DATE_MESSAGE)
    end
  end

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

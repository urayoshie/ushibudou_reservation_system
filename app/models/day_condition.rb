class DayCondition < ApplicationRecord
  include PerUnitMin
  DAY_LIST = (0..6)

  validates :applicable_date, uniqueness: {
                                scope: :wday,
                                message: "で同じ曜日のデータは複数登録できません",
                              }
  validates :wday, presence: true, numericality: { in: DAY_LIST }

  validate :per_unit_start_min
  validate :per_unit_end_min
  validate :under_limit_unit
  validate :prevent_earlier_date

  PREVENT_EARLIER_DATE_MESSAGE = "は初期設定より早い日付で登録できません"

  # 初期設定より早い日付で登録できないようにする
  def prevent_earlier_date
    if DayCondition.count.positive?
      earliest_date = DayCondition.order(applicable_date: :asc).first&.applicable_date
      if applicable_date < earliest_date
        errors.add(:applicable_date, PREVENT_EARLIER_DATE_MESSAGE)
      end
    end
  end

  # start_date から end_date までの規定営業日の配列を取得
  def self.default_business_dates(start_date, end_date)
    (start_date..end_date).to_a - default_closed_dates(start_date, end_date)

    # a_week = DAY_LIST.to_a
    # # 登録済みの定休日適用日の配列
    # total_appllicable_days = DayCondition.where(start_min: nil).pluck(:applicable_date)

    # today = Date.today
    # # 今日を起点に適応するべき適応日
    # appllicable_days = []
    # total_appllicable_days.each do |total_appllicable_day|
    #   if today > total_appllicable_day
    #     appllicable_days << total_appllicable_day
    #   end
    # end

    # # 今日を起点に適応するべき適応日に対する定休日
    # closed_days = DayCondition.where(applicable_date: appllicable_days, start_min: nil).pluck(:wday)

    # business_wdays = a_week - closed_days

    # closed_day = DayCondition.where(start_min: nil).where("applicable_date <= ?", end_date).distinct.pluck(:wday)
  end

  # start_date から end_date までの規定休業日の配列を取得
  def self.default_closed_dates(start_date, end_date)
    # 休業日設定の入っている曜日の配列
    closed_wdays = DayCondition.where("applicable_date <= ?", end_date).where(start_min: nil).pluck(:wday)

    # 休業日設定の入っている曜日のデータを曜日ごとにまとめる
    closed_day_conditions = DayCondition.where("applicable_date <= ?", end_date).where(wday: closed_wdays).order(applicable_date: :asc).select(:applicable_date, :start_min, :wday).group_by { |i| i.wday }

    # 開始日から終了日を曜日ごとに分けたハッシュ
    date_list = (start_date..end_date).to_a.group_by { |date| date.wday }

    closed_dates = []
    closed_day_conditions.each do |wday, day_conditions|
      reverse_day_conditions = day_conditions.reverse
      # date_list[wday] は、開始日から終了日の内、 wday に対応する曜日のみの配列
      closed_dates += date_list[wday].select do |date|
        applicable_day_condition = reverse_day_conditions.find { |day_condition| date >= day_condition.applicable_date }
        applicable_day_condition.start_min.nil?
      end
    end
    closed_dates
  end
end

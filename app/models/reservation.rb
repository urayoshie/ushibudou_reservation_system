class Reservation < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # VALID_PHONE_NUMBER_REGEX = /\A0(\d{1}[-(]?\d{4}|\d{2}[-(]?\d{3}|\d{3}[-(]?\d{2}|\d{4}[-(]?\d{1})[-)]?\d{4}\z|\A0[5789]0[-]?\d{4}[-]?\d{4}\z/
  VALID_PHONE_NUMBER_REGEX = /\A0\d{1,3}-?\d{2,4}-?\d{3,4}\z/

  # PER_MIN = 15
  # LIMITE_MIN = 120

  # START_TIME = 15
  # END_TIME = 25
  # LASTORDER_TIME = 23
  # WHOLEDAY_COUNT = (END_TIME - START_TIME) * (60 / PER_MIN)
  # TILL_LASTORSER_COUNT = (LASTORDER_TIME - START_TIME) * (60 / PER_MIN) + 1
  # PERMITTED_MINUTES = [0, 15, 30, 45]
  MAXIMUM_GUEST_NUMBER = 12
  ACCEPTABLE_PRIVATE_NUMBER = 6

  PERIOD_MONTH = 3.months

  PAST_ERROR_MESSAGE = "は本日以降の日付を選択してください"
  AFTER_THREE_MONTHS_ERROR_MESSAGE = "は本日より#{PERIOD_MONTH.in_months.round}ヶ月未満の日付を選択してください"
  CLOSED_MESSAGE = "は営業日を選択してください"
  UNIT_MESSAGE = "は#{ConvertTime::PER_MIN}分ごとの時間を選択してください"
  CLOSED_HOURS_MESSAGE = "は営業時間内で選択してください"

  validates :guest_number, :start_at, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :phone_number, presence: true, format: { with: VALID_PHONE_NUMBER_REGEX }
  validates :request, length: { maximum: 300 }

  # start_at は 15時〜23時以外はいらない様にバリデーションを入れる
  # validates_time :start_at, between: ["15:00", "23:00"]
  # 15分毎(0, 15, 30, 45)以外はいらない様にバリデーションを入れる
  # validate :min_only
  # 本日以前の日付は入らないようにする
  validate :date_before_start
  # 本日から3ヶ月目以降の日付は入らないようにする
  validate :date_after_three_months
  # start_at が 営業日 かつ 開始時間〜終了時間(15×8 分前) かつ 15分区切り であること
  validate :within_business_hours

  ###### バリデーション ######
  def min_only
    # if PERMITTED_MINUTES.include?(start_at.min)
    #   true
    # else
    #   errors.add(:start_at, "must be 0, 15, 30, and 45")
    # end
  end

  def date_before_start
    errors.add(:start_at, PAST_ERROR_MESSAGE) if start_at < Date.today
  end

  def date_after_three_months
    errors.add(:start_at, AFTER_THREE_MONTHS_ERROR_MESSAGE) if start_at > (Date.today + PERIOD_MONTH)
  end

  def within_business_hours
    start_min, end_min = Reservation.fetch_business_hours(start_at)
    if start_min.nil? || end_min.nil?
      errors.add(:start_at, CLOSED_MESSAGE) and return
    end

    limit_min = end_min - ConvertTime::RESERVED_MIN
    chosen_min = ConvertTime.to_min(start_at.strftime("%H:%M"))

    if start_min.nil?
      errors.add(:start_at, CLOSED_MESSAGE)
    elsif chosen_min % ConvertTime::PER_MIN != 0
      errors.add(:start_at, UNIT_MESSAGE)
    elsif start_min > chosen_min || chosen_min > limit_min
      errors.add(:start_at, CLOSED_HOURS_MESSAGE)
    end
  end

  ###### クラスメソッド ######
  class << self

    # 引数の日付の「営業時間」を取得するメソッド
    def fetch_business_hours(datetime)
      date = datetime.to_date
      temporary_date = TemporaryDate.find_by(date: date)
      if temporary_date
        return [temporary_date[:start_min], temporary_date[:end_min]]
      end

      business_day = DayCondition.order(created_at: :desc).where(wday: date.wday).find_by("applicable_date <= ?", date)
      if business_day
        return [business_day[:start_min], business_day[:end_min]]
      end
      [nil, nil]
    end

    # start_date から end_date までの営業日の配列を取得
    def calc_business_dates(start_date, end_date)
      dates = (start_date..end_date).to_a
      # 規定営業日の配列
      default_business_dates = DayCondition.default_business_dates(start_date, end_date)
      # 臨時営業日の配列
      temporary_business_dates = TemporaryDate.business_dates(start_date, end_date)
      # 臨時休業日の配列
      temporary_closed_dates = TemporaryDate.closed_dates(start_date, end_date)

      ((default_business_dates + temporary_business_dates).uniq - temporary_closed_dates).sort
      # 営業日
      # DayCondition.where("applicable_date <= ?", end_date).order(applicable_date: :asc).group_by { |i| i.wday }.each do |wday, conditions|
      # end

      # closed_days = (DayCondition::DAY_LIST.to_a - DayCondition.distinct.pluck(:wday)) + DayCondition.where(start_min: nil).where("applicable_date <= ?", end_date).distinct.pluck(:wday)
      # closed_dates = dates.select { |date| date.wday.in?(closed_days) }
      # default_closed_dates = DayCondition.where(date: start_date..end_date, start_min: nil, wday: 3)
      # [start_date..end_date].to_a - temporary_closed_dates - default_closed_dates
    end

    # 予約人数と貸切予約かどうかの1日単位(15:00~24:45)の配列ハッシュデータ
    def reserve_list(datetime, exclude_reservation_id = nil)
      # beginning_of_day = date.beginning_of_day
      # end_of_day = date.end_of_day

      base_datetime = datetime.beginning_of_day
      start_min, end_min = fetch_business_hours(base_datetime)

      # 【重要】エラーを通知する
      return [] if start_min.nil?

      beginning_of_day = base_datetime + start_min.minutes
      end_of_day = base_datetime + end_min.minutes

      error = false
      # list = (0..count).map do |i|
      #   { time: beginning_of_day + (i * PER_MIN).minute, number: 0 }
      # end

      # # それぞれの時間の予約の合計人数
      # where(start_at: beginning_of_day..end_of_day).each do |reservation|
      #   start_unit = (reservation.start_at - beginning_of_day).floor / 60 / PER_MIN
      #   # list2 = list[start_unit][:number]
      #   8.times do |i|
      #     list[start_unit + i][:number] += reservation.guest_number
      #   end
      # end
      reservation_list = []
      total_units = ConvertTime.total_units(start_min, end_min)
      total_units.times do
        reservation_list << { total_number: 0, private_reservation: false }
      end

      where(start_at: beginning_of_day..end_of_day).where.not(id: exclude_reservation_id).each do |reservation|
        diff_seconds = (reservation.start_at - beginning_of_day).floor
        start_unit = ConvertTime.sec_to_unit(diff_seconds)
        ConvertTime::LIMITE_UNITS.times do |i|
          reservation_params = reservation_list[start_unit + i]
          if reservation.guest_number >= ACCEPTABLE_PRIVATE_NUMBER
            if reservation_params[:private_reservation]
              # 貸切の二重予約があったとき
              reservation_params[:error] = true
            elsif reservation_params[:total_number] > 0
              # 予約があるのに貸切しようとしたとき
              reservation_params[:error] = true
            else
              reservation_params[:private_reservation] = true
            end
          end

          reservation_params[:total_number] += reservation.guest_number

          # 予約人数がオーバーしているとき
          reservation_params[:error] = true if reservation_params[:total_number] > MAXIMUM_GUEST_NUMBER

          # reservation_list[start_unit + i][:total_number] += reservation.guest_number
          # if reservation.private_reservation
          #   reservation_list[start_unit + i][:private_reservation] = true
          # end
        end
      end

      # list = total_numbers.map.with_index do |total_number, i|
      #   { time: beginning_of_day + (i * PER_MIN).minute, total_number: total_number }
      # end
      reservation_list
    end

    # def list
    #   (0..7).map do |i|
    #     { time: start_at + PER_MIN.minute * i, number: guest_number }
    #   end
    # end

    # 1日(15:00~23:00)2時間単位での予約最大人数と貸切予約の有無の配列ハッシュデータ
    def biggest_num_list(datetime, exclude_reservation_id = nil)
      reservation_list = reserve_list(datetime, exclude_reservation_id)

      biggest_number_list = []

      (reservation_list.size - ConvertTime::LIMITE_UNITS + 1).times do |i|
        list = reservation_list.slice(i..(i + ConvertTime::LIMITE_UNITS - 1))

        biggest_number = list.max_by { |k| k[:total_number] }[:total_number]

        # reservable_num_list(datetime)���12から引いたものでは���いものにしたいので以下1行を外す
        # 12か��引いたもののリストはまた別でメソッドを作る
        # reservable_number = MAXIMUM_GUEST_NUMBER - biggest_number

        # boolean_list = list.map { |data| data[:private_reservation] }
        # private_reservation = boolean_list.inject do |result, data|
        #   result || data
        # end
        # private_reservation = boolean_list.inject { |data| result || data }
        # private_reservation = list.inject(false) { |result, data| result || data[[:total_number]] }
        # available_seats_list[:private_reservation_exists] = true
        # private_reservation = list.inject(false) { |result, data| result || data[:private_reservation] }
        private_reservation = list.any? { |data| data[:private_reservation] }
        error = list.any? { |data| data[:error] }
        biggest_number_list << { biggest_number: biggest_number, private_reservation_exists: private_reservation, error: error }
      end
      biggest_number_list
    end

    # # 空き人数と貸切予約の有無の1日単位(15:00~23:00)の配列ハッシュデータ
    # def reservable_num_list(datetime)
    #   reservation_list = reserve_list(datetime)

    #   available_seats_list = []

    #   (reservation_list.size - 7).times do |i|
    #     list = reservation_list.slice(i..i + 7)

    #     biggest_number = list.max_by { |k| k[:total_number] }[:total_number]

    #     # reservable_num_list(datetime)は12から引いたものではないも��にし���いの��以下1行を外す
    #     # 12か���引いたもののリストはまた別でメ����ドを作る
    #     reservable_number = MAXIMUM_GUEST_NUMBER - biggest_number

    #     # boolean_list = list.map { |data| data[:private_reservation] }
    #     # private_reservation = boolean_list.inject do |result, data|
    #     #   result || data
    #     # end
    #     # private_reservation = boolean_list.inject { |data| result || data }
    #     # private_reservation = list.inject(false) { |result, data| result || data[[:total_number]] }
    #     # available_seats_list[:private_reservation_exists] = true
    #     # private_reservation = list.inject(false) { |result, data| result || data[:private_reservation] }
    #     private_reservation = list.any? { |data| data[:private_reservation] }
    #     available_seats_list << { reservable_number: reservable_number, private_reservation_exists: private_reservation }
    #   end
    #   available_seats_list
    # end

    # 1日あた���の15:00~23:00の15��単位での予約受��の真偽判定
    def display_available_time(datetime, guest_number, exclude_reservation_id = nil)
      # array = reservable_num_list(datetime)
      reservable_array = []
      # biggest_num_list(datetime)

      biggest_num_list(datetime, exclude_reservation_id).map do |data|
        # if guest_number <= data[:reservable_number] && data[:private_reservation_exists] == false
        #   reservable_array << true
        # else
        #   reservable_array << false
        # end
        reservable_number = MAXIMUM_GUEST_NUMBER - data[:biggest_number]
        reservable_array << (guest_number <= reservable_number && !data[:private_reservation_exists])
      end
      #     reservable_number_array = available_seats_list.map { |data| data[:reservable_number] }
      # private_reservation_exists_array = available_seats_list.map { |data| data[:private_reservation_exists] }
      # array = []

      # array << reservable_number_array.zip(private_reservation_exists_array) do |reservable_number, private_reservation_exists|
      #   if guest_number <= reservable_number && private_reservation_exists == false
      #     array << true
      #   else
      #     array << false
      #   end
      # end
      reservable_array
    end

    # 貸切予約が出来るかどうかの真偽配列
    def choose_private_reservation(datetime, exclude_reservation_id = nil)
      # reservation_list = reserve_list(datetime)
      # available_seats_list = biggest_num_list(datetime)

      reservable_private_reservation = []
      biggest_num_list(datetime, exclude_reservation_id).map do |data|
        # if data[:reservable_number] == MAXIMUM_GUEST_NUMBER
        #   reservable_private_reservation << true
        # else
        #   reservable_private_reservation << false
        # end
        # reservable_number = MAXIMUM_GUEST_NUMBER - data[:biggest_number]
        reservable_private_reservation << data[:biggest_number].zero?
        # reservable_private_reservation << data[:reservable_number] == 12 && !data[:private_reservation_exists]
      end
      reservable_private_reservation
    end

    def reservable_list(datetime, guest_number, exclude_reservation_id = nil)
      # 6人以上なら貸切用のメソッド, 6人未満なら人数用のメソッド
      if guest_number >= 6
        choose_private_reservation(datetime, exclude_reservation_id)
      else
        display_available_time(datetime, guest_number, exclude_reservation_id)
      end
    end

    # 1日単位で1コマ(例えば15::00からの8コマ2時間)でも予約可能な場合はtrue,一つも空きが無い場合はfalseを返す。show_string_datetime(guest_number)のif文に移動。
    # def show_reservable_date(date, guest_number)
    #   # reservable_array = display_available_time(date, guest_number)

    #   # show_date = reservable_array.any?
    #   display_available_time(date, guest_number).any?
    # end

    # 今日から3ヶ月までの期間、予約可能な日付を文字列で配列に格納
    def show_string_date(guest_number)
      start_date = Date.current
      end_date = start_date + PERIOD_MONTH
      # reserved_date_list = Reservation.where(start_at: Date.current..(Date.current + 3.months)).distinct.pluck(:start_at).map(&:to_date).uniq

      # reservable_date_range = Date.current..(Date.current + PERIOD_MONTH)

      # 営業日
      business_dates = calc_business_dates(start_date, end_date)

      # 予約出来ない日の配列
      not_available_date_list = if guest_number < ACCEPTABLE_PRIVATE_NUMBER
          # guest_number が５以下のとき、予約できない日付の配列
          # minimum_total_num がどの範囲なら予約できないか？ => minimum_total_num + guest_num > MAXIMUM_GUEST_NUMBER
          ReservationStatus.where("minimum_total_num > ?", MAXIMUM_GUEST_NUMBER - guest_number).where(date: business_dates).pluck(:date)
        else
          # 貸切（guest_number が6以上）のとき、予約できない日付の配列
          ReservationStatus.where(date: business_dates).pluck(:date)
        end

      business_dates - not_available_date_list
      # available_date_list = (reservable_date_range.to_a - not_available_date_list)
      # available_date_list = (reservable_date_range.to_a - not_available_date_list).select { |date| date.wday != 2 }
      # available_date_list = (business_dates.to_a - not_available_date_list).select do |date|
      #   date.wday != 2
      # end

      # reservable_date_range.to_a.each do |date|
      #   available_date_list << date if not_available_date_list.exclude?(date)
      # end

      # available_date_list

      # display_available_time(date, guest_number).any?
      # Date.current.upto(Date.current + 3.months) do |date|
      #   # 火曜日は予約できないので含めない
      #   next if date.wday == 2
      #   # 予約がない日、または、予約はあるが予約できる日
      #   # if reserved_date_list.exclude?(date) || reservable_list(date, guest_number).any?
      #   #   available_date_list << date.strftime
      #   # end

      # end
      # available_date_list
    end
  end
end

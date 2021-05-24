class Reservation < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # VALID_PHONE_NUMBER_REGEX = /\A0(\d{1}[-(]?\d{4}|\d{2}[-(]?\d{3}|\d{3}[-(]?\d{2}|\d{4}[-(]?\d{1})[-)]?\d{4}\z|\A0[5789]0[-]?\d{4}[-]?\d{4}\z/
  VALID_PHONE_NUMBER_REGEX = /\A0\d{1,3}-?\d{2,4}-?\d{3,4}\z/
  TERM = 15
  START_TIME = 15
  END_TIME = 25
  LASTORDER_TIME = 23
  WHOLEDAY_COUNT = (END_TIME - START_TIME) * (60 / TERM)
  TILL_LASTORSER_COUNT = (LASTORDER_TIME - START_TIME) * (60 / TERM) + 1
  MAXIMUM_GUEST_NUMBER = 12
  ACCEPTABLE_PRIVATE_NUMBER = 6

  PERIOD_MONTH = 3.months
  PAST_ERROR_MESSAGE = "本日以降の日付を選択してください"
  # AFTER_THREE_MONTHS_ERROR_MESSAGE = "本日より#{PERIOD_MONTH.in_months.round}ヶ月未満の日付を選択してください"

  validates :guest_number, :started_at, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :phone_number, presence: true, format: { with: VALID_PHONE_NUMBER_REGEX }
  validates :request, length: { maximum: 300 }
  # started_at は 15時〜23時以外はいらない様にバリデーションを入れる
  validates_time :started_at, between: ["15:00", "23:00"]
  # 15分毎(0, 15, 30, 45)以外はいらない様にバリデーションを入れる
  validate :min_only
  # 本日以前の日付は入らないようにする
  validate :date_before_start
  # 本日から3ヶ月目以降の日付は入らないようにする
  validate :date_after_three_months

  PERMITTED_MINUTES = [0, 15, 30, 45]

  def min_only
    if PERMITTED_MINUTES.include?(started_at.min)
      true
    else
      errors.add(:started_at, "must be 0, 15, 30, and 45")
    end
  end

  def date_before_start
    errors.add(:started_at, PAST_ERROR_MESSAGE) if started_at < Date.today
  end

  def date_after_three_months
    errors.add(:started_at, AFTER_THREE_MONTHS_ERROR_MESSAGE) if started_at > (Date.today + PERIOD_MONTH)
  end

  # 予約人数と貸切予約かどうかの1日単位(15:00~24:45)の配列ハッシュデータ
  def self.reserve_list(date)
    # beginning_of_day = date.beginning_of_day
    # end_of_day = date.end_of_day

    date = date.beginning_of_day

    beginning_of_day = date + START_TIME.hours
    end_of_day = date + END_TIME.hours

    error = false
    # list = (0..count).map do |i|
    #   { time: beginning_of_day + (i * TERM).minute, number: 0 }
    # end

    # # それぞれの時間の予約の合計人数
    # where(started_at: beginning_of_day..end_of_day).each do |reservation|
    #   start_index = (reservation.started_at - beginning_of_day).floor / 60 / TERM
    #   # list2 = list[start_index][:number]
    #   8.times do |i|
    #     list[start_index + i][:number] += reservation.guest_number
    #   end
    # end
    reservation_list = []
    WHOLEDAY_COUNT.times do
      reservation_list << { total_number: 0, private_reservation: false }
    end

    where(started_at: beginning_of_day..end_of_day).each do |reservation|
      start_index = (reservation.started_at - beginning_of_day).floor / 60 / TERM
      8.times do |i|
        reservation_params = reservation_list[start_index + i]
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

        # reservation_list[start_index + i][:total_number] += reservation.guest_number
        # if reservation.private_reservation
        #   reservation_list[start_index + i][:private_reservation] = true
        # end
      end
    end

    # list = total_numbers.map.with_index do |total_number, i|
    #   { time: beginning_of_day + (i * TERM).minute, total_number: total_number }
    # end
    reservation_list
  end
  # def list
  #   (0..7).map do |i|
  #     { time: started_at + TERM.minute * i, number: guest_number }
  #   end
  # end

  # 1日(15:00~23:00)2時間単位での予約最大人数と貸切予約の有無の配列ハッシュデータ
  def self.biggest_num_list(date)
    reservation_list = reserve_list(date)

    biggest_number_list = []

    (reservation_list.size - 7).times do |i|
      list = reservation_list.slice(i..i + 7)

      biggest_number = list.max_by { |k| k[:total_number] }[:total_number]

      # self.reservable_num_list(date)は12から引いたものではないものにしたいので以下1行を外す
      # 12から引いたもののリストはまた別でメソッドを作る
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
  # def self.reservable_num_list(date)
  #   reservation_list = reserve_list(date)

  #   available_seats_list = []

  #   (reservation_list.size - 7).times do |i|
  #     list = reservation_list.slice(i..i + 7)

  #     biggest_number = list.max_by { |k| k[:total_number] }[:total_number]

  #     # self.reservable_num_list(date)は12から引いたものではないものにしたいので以下1行を外す
  #     # 12から引いたもののリストはまた別でメソッドを作る
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

  # 1日あたりの15:00~23:00の15分単位での予約受入の真偽判定
  def self.display_available_time(date, guest_number)
    # array = reservable_num_list(date)
    reservable_array = []
    # biggest_num_list(date)

    biggest_num_list(date).map do |data|
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

  # 貸切予約が出来るかどうかの真��配列
  def self.choose_private_reservation(date)
    # reservation_list = reserve_list(date)
    # available_seats_list = biggest_num_list(date)

    reservable_private_reservation = []
    biggest_num_list(date).map do |data|
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

  def self.reservable_list(date, guest_number)
    # 6人以上なら貸切用のメソッド, 6人未満なら人数用のメソッド
    if guest_number >= 6
      choose_private_reservation(date)
    else
      display_available_time(date, guest_number)
    end
  end

  # 1日単位で1コマ(例えば15::00からの8コマ2時間)でも予約可能な場合はtrue,一つも空きが無い場合はfalseを返す。self.show_string_date(guest_number)のif文に移動。
  # def self.show_reservable_date(date, guest_number)
  #   # reservable_array = display_available_time(date, guest_number)

  #   # show_date = reservable_array.any?
  #   display_available_time(date, guest_number).any?
  # end

  # 今日から3ヶ月までの期間、予約可能な日付を文字列で配列に格納
  def self.show_string_date(guest_number)
    # reserved_date_list = Reservation.where(started_at: Date.current..(Date.current + 3.months)).distinct.pluck(:started_at).map(&:to_date).uniq

    reservable_date_range = Date.current..(Date.current + PERIOD_MONTH)

    # 予約出来ない日の配列
    not_available_date_list = if guest_number < ACCEPTABLE_PRIVATE_NUMBER
        # guest_number が５以下のとき、予約できない日付の配列
        # minimum_total_num がどの範囲なら予約できないか？ => minimum_total_num + guest_num > MAXIMUM_GUEST_NUMBER
        ReservationStatus.where("minimum_total_num > ?", MAXIMUM_GUEST_NUMBER - guest_number).where(date: reservable_date_range).pluck(:date)
      else
        # 貸切（guest_number が6以上）のとき、予約できない日付の配列
        ReservationStatus.where(date: reservable_date_range).pluck(:date)
      end

    # available_date_list = (reservable_date_range.to_a - not_available_date_list)
    # available_date_list = (reservable_date_range.to_a - not_available_date_list).select { |date| date.wday != 2 }
    available_date_list = (reservable_date_range.to_a - not_available_date_list).select do |date|
      date.wday != 2
    end

    # reservable_date_range.to_a.each do |date|
    #   available_date_list << date if not_available_date_list.exclude?(date)
    # end

    available_date_list

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

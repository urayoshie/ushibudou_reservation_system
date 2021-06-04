class ReservationStatus < ApplicationRecord
  # 基本的なバリデーションは入れる
  # 日付 YYYY-MM-DD
  VALID_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/
  RESERVATION_OVER_MESSAGE = "申し訳ありません。\n予約人数を越えました。\n再度、予約人数、予約日、予約時間をお選びください。"

  validates :minimum_total_num, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 }
  validates :date, presence: true, uniqueness: true  #, :format {with: VALID_DATE_REGEX}

  def self.update_reservation_status!(date)
    # biggest_num_list を呼び出す
    biggest_list = Reservation.biggest_num_list(date)
    error = biggest_list.any? { |data| data[:error] }

    if error
      OutputLog.info(
        date: date,
        message: "予約のできない状態で予約が入ろうとしました。",
      )
      raise RESERVATION_OVER_MESSAGE
    end

    # array = []
    # biggest_list.each do |list|
    #   array << list[:biggest_number] unless list[:private_reservation_exists]
    # end
    # minimum_total_num = array.min

    # minimum_total_num =
    minimum_total_num = biggest_list.inject(Reservation::MAXIMUM_GUEST_NUMBER) do |result, list|
      (!list[:private_reservation_exists] && list[:biggest_number] < result) ? list[:biggest_number] : result
    end

    # private_reservation_available =
    # array = []
    # biggest_list.each do |list|
    #   array << list[:biggest_number]
    # end
    # private_reservation_available = array.include?(0)

    if minimum_total_num > 0
      reservation_status = ReservationStatus.find_or_initialize_by(date: date)
      reservation_status.update!(minimum_total_num: minimum_total_num)
    end
  end
end

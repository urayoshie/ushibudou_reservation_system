class ReservationsController < ApplicationController
  MINIMUM_PRIVATE_NUMBER = 6

  def index
    # @default_days = [
    #   "2021-05-14",
    #   "2021-05-24",
    # ]
    # date = Date.new(2021, 5, 3)
    # guest_number = 3
    # Reservation.reserve_list(date)
    # list = Reservation.reservable_num_list(date)
    # available_time_list = Reservation.display_available_time(date, guest_number)
    # available_seats_list = Reservation.choose_private_reservation(date)
    # reservable_array = Reservation.show_reservable_date(date, guest_number)
    # show_date = Reservation.show_string_date(guest_number)

  end

  def available_dates
    guest_number = params["guest_number"].to_i
    date = params["date"].to_date
    # available_dates = Reservation.show_string_date(guest_number)

    available_dates = Reservation.show_string_date(guest_number)
    available_time = []
    # 日付が既に選択(present)されている場合において、予約人数を変更した時に予約可能時間を出す
    # !date.past? は過去の日付を弾く
    if date.present? && !date.past?
      available_time = calc_available_time(date, guest_number)
      # elsif date.past?
      #   errors.add(:date, "適切な日付が選択されていません")
      # else：日付が選択されていない(presentでない)時に、入力された予約人数に対して予約可能日を出すのでavailable_timeには初期値のnilが入ってデータが渡る
    end
    render json: { availableDates: available_dates, availableTime: available_time }
  end

  def available_time
    # 1日単位で15:00~23:00の15分単位で予約可能な時間の配列(文字列)
    guest_number = params["guest_number"].to_i
    date = params["date"].to_date
    # checked = params[:checked].present?
    # 貸切かどうか
    # reservable = ~~~~

    # available_time = []

    # # boolean_list = Reservation.display_available_time(date, guest_number)
    # # time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    # # boolean_list.each do |boolean|
    # #   binding.pry
    # #   if (guest_number >= MINIMUM_PRIVATE_NUMBER && checked)
    # #     available_time <<
    # #   else
    # #   end
    # # end

    # # 人数を選択した場合(1日あたりの15:00~23:00の15分単位での予約受入の真偽判定)
    # boolean_list = Reservation.reservable_list(date, guest_number)
    # time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    # boolean_list.each do |boolean|
    #   available_time << time.strftime("%H:%M") if boolean
    #   time += 15.minute
    # end
    # available_time
    # # 貸切の場合(貸切予約が出来るかどうかの真偽配列)
    # checkbox_list = []
    # private_boolean_list = Reservation.choose_private_reservation(date)
    # private_boolean_list.each do |private_boolean|
    #   # 予約人数が6人以上で貸切予約が出来る場合trueを返す
    #   checkbox_list << (guest_number >= MINIMUM_PRIVATE_NUMBER && private_boolean)
    # end
    # render json: { availableTime: available_time, checkboxList: checkbox_list }

    available_time = []
    # 日付が既に選択(present)されている場合において、予約人数を変更した時に予約可能時間を出す
    if date.present? && !date.past?
      available_time = calc_available_time(date, guest_number)
    end
    # available_time = calc_available_time(date, guest_number)
    render json: { availableTime: available_time }
  end

  private

  def calc_available_time(date, guest_number)
    available_time = []

    # boolean_list = Reservation.display_available_time(date, guest_number)
    # time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    # boolean_list.each do |boolean|
    #   binding.pry
    #   if (guest_number >= MINIMUM_PRIVATE_NUMBER && checked)
    #     available_time <<
    #   else
    #   end
    # end

    # 人数を選択した場合(1日あたりの15:00~23:00の15分単位での予約受入の真偽判定)
    boolean_list = Reservation.reservable_list(date, guest_number)
    time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    boolean_list.each do |boolean|
      available_time << time.strftime("%H:%M") if boolean
      time += 15.minute
    end
    available_time
  end
end

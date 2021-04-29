class ReservationsController < ApplicationController
  PRIVATE_NUMBER = 6..12

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
    available_dates = Reservation.show_string_date(guest_number)
    render json: { availableDates: available_dates }
  end

  def available_time
    # 1日単位で15:00~23:00の15分単位で予約可能な時間の配列(文字列)

    guest_number = params["guest_number"].to_i
    date = params["date"].to_date
    # 貸切かどうか
    # reservable = ~~~~

    available_time = []

    # 人数をした場合(1日あたりの15:00~23:00の15分単位での予約受入の真偽判定)
    boolean_list = Reservation.display_available_time(date, guest_number)
    time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    boolean_list.each do |boolean|
      available_time << time.strftime("%H:%M") if boolean
      time += 15.minute
    end
    # 貸切の場合(貸切予約が出来るかどうかの真偽配列)
    private_checkbox_list = []
    private_boolean_list = Reservation.choose_private_reservation(date)
    binding.pry
    # private_boolean_list.each do |private_boolean|
    #   if guest_number >= PRIVATE_NUMBER && private_boolean
    #     private_checkbox_list <<
    #   end
    # end
    render json: { availableTime: available_time }
  end
end

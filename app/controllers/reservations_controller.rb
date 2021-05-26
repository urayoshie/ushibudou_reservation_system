class ReservationsController < ApplicationController
  MINIMUM_PRIVATE_NUMBER = 6

  def index
    # @default_days = [
    #   "2021-05-14",
    #   "2021-05-24",
    # ]
    # date = Date.new(2021, 6, 4)
    # guest_number = 3
    # Reservation.reserve_list(date)
    # list = Reservation.reservable_num_list(date)
    # available_time_list = Reservation.display_available_time(date, guest_number)
    # available_seats_list = Reservation.choose_private_reservation(date)
    # reservable_array = Reservation.show_reservable_date(date, guest_number)
    # show_date = Reservation.show_string_date(guest_number)
    # Reservation.update_reservation_status(date)
    @number_list = (1..Reservation::MAXIMUM_GUEST_NUMBER).to_a
    # reservation = Reservation.find_by(start_at: (Date.new(2021, 6, 2).beginning_of_day)..(Date.new(2021, 6, 2).end_of_day))
    # reservation.update_reservation_status
  end

  def create
    ActiveRecord::Base.transaction do
      reservation = Reservation.create!(reservation_params)
      reservation_date = reservation.start_at.to_date
      ReservationStatus.update_reservation_status!(reservation_date)

      date = reservation.start_at.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[Time.now.wday]})")
      time = reservation.start_at.strftime("%-H:%M")
      flash[:notice] = "#{reservation.guest_number}名様 / #{date} / #{time}"
      render json: {}, status: :no_content
    end
  rescue => e
    message = case e.message
      when ReservationStatus::RESERVATION_OVER_MESSAGE
        e.message
      when /#{Reservation::PAST_ERROR_MESSAGE}/
        Reservation::PAST_ERROR_MESSAGE
      else
        "エラーが発生しました。"
      end

    render json: { error: message }, status: :forbidden

    # name = params[:reservation][:name]
    # email = params[:reservation][:email]
    # phone_number = params[:reservation][:phone_number]
    # request = params[:reservation][:request]
    # guest_number = params[:reservation][:guest_number]
    # # date = params[:list][:date]
    # # time = params[:list][:time]
    # # start_at = [:reservation][:date] + [:reservation][:time]
    # start_at = params[:reservation][:start_at]
  end

  def confirmation
    redirect_to reservations_path if flash[:notice].nil?
  end

  def available_dates
    guest_number = params["guest_number"].to_i
    date = params["date"]&.to_date
    exclude_reservation_id = params[:exclude_reservation_id]&.to_i

    available_dates = Reservation.show_string_date(guest_number)

    if exclude_reservation_id
      # 管理画面の編集ページで、編集中の予約の日付が含まれていない場合
      # 実際には選択できるかもしれないので、再計算する
      reservation = Reservation.find(exclude_reservation_id)
      reserved_date = reservation[:start_at].to_date # reservation_id に対応する 予約 の日付
      if available_dates.exclude?(reserved_date) && Reservation.reservable_list(reserved_date, guest_number, exclude_reservation_id).any?
        available_dates << reserved_date
      end
    end

    available_time = []
    # 日付が既に選択(present)されている場合において、予約人数を変更した時に予約可能時間を出す
    # !date.past? は過去の日付を弾く
    if date.present? && !date.past?
      available_time = calc_available_time(date, guest_number, exclude_reservation_id)
      # elsif date.past?
      #   errors.add(:date, "適切な日付が選択されていません")
      # else：日付が選択されていない(presentでない)時に、入力された予約人数に対して予約可能日を出すのでavailable_timeには初期値のnilが入ってデータが渡る
    end
    render json: { availableDates: available_dates, availableTime: available_time }
  end

  def available_time
    # 1日単位で15:00~23:00の15分単位で予約可能な時間の配列(文字列)
    guest_number = params[:guest_number].to_i
    date = params[:date].to_date
    exclude_reservation_id = params[:exclude_reservation_id]&.to_i
    # checked = params[:checked].present?
    # 貸切かどうか
    # reservable = ~~~~

    # available_time = []

    # # boolean_list = Reservation.display_available_time(date, guest_number)
    # # time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    # # boolean_list.each do |boolean|
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
      available_time = calc_available_time(date, guest_number, exclude_reservation_id)
    end
    # available_time = calc_available_time(date, guest_number)
    render json: { availableTime: available_time }
  end

  private

  def calc_available_time(date, guest_number, exclude_reservation_id = nil)
    available_time = []

    # boolean_list = Reservation.display_available_time(date, guest_number)
    # time = Time.new(2000, 1, 1, Reservation::START_TIME, 0, 0)
    # boolean_list.each do |boolean|
    #   if (guest_number >= MINIMUM_PRIVATE_NUMBER && checked)
    #     available_time <<
    #   else
    #   end
    # end

    # 人数を選択した場合(1日あたりの15:00~23:00の15分単位での予約受入の真偽判定)
    boolean_list = Reservation.reservable_list(date, guest_number, exclude_reservation_id)
    time = Time.new(date.year, date.mon, date.day, Reservation::START_TIME, 0, 0)
    boolean_list.each do |boolean|
      if date == Date.today
        if boolean && time > Time.current
          available_time << time.strftime("%H:%M")
        end
      else
        available_time << time.strftime("%H:%M") if boolean
      end
      time += 15.minute
    end

    available_time
  end

  def reservation_params
    params.require(:reservation).permit(:name, :email, :phone_number, :request, :guest_number, :start_at)
  end
end

class ReservationsController < ApplicationController
  MINIMUM_PRIVATE_NUMBER = 6

  def index
    @number_list = (1..Reservation::MAXIMUM_GUEST_NUMBER).to_a
  end

  def create
    ActiveRecord::Base.transaction do
      reservation = Reservation.create!(reservation_params)
      ReservationStatus.update_reservation_status!(reservation.date)
      date = I18n.l(reservation.date, format: :info)
      time = params[:reservation][:time]
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
      if available_dates.exclude?(reservation.date) && Reservation.reservable_list(reservation.date, guest_number, exclude_reservation_id).any?
        available_dates << reservation.date
      end
    end

    available_time = []
    # 日付が既に選択(present)されている場合において、予約人数を変更した時に予約可能時間を出す
    # !date.past? は過去の日付を弾く
    if date.present? && !date.past?
      available_time = Reservation.calc_available_time(date, guest_number, exclude_reservation_id)
    end
    render json: { availableDates: available_dates, availableTime: available_time }
  end

  def available_time
    # 1日単位で15:00~23:00の15分単位で予約可能な時間の配列(文字列)
    guest_number = params[:guest_number].to_i
    date = params[:date].to_date
    exclude_reservation_id = params[:exclude_reservation_id]&.to_i

    available_time = []
    # 日付が既に選択(present)されている場合において、予約人数を変更した時に予約可能時間を出す
    if date.present? && !date.past?
      available_time = Reservation.calc_available_time(date, guest_number, exclude_reservation_id)
    end
    render json: { availableTime: available_time }
  end

  private

  def reservation_params
    params.require(:reservation).permit(:name, :email, :phone_number, :request, :guest_number, :date).merge build_time_param
  end

  def build_time_param
    { start_min: ConvertTime.to_min(params[:reservation][:start_time]) }
  end
end

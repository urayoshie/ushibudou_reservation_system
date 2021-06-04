class Admin::ReservationsController < Admin::AdminController
  before_action :set_reservation, only: %i[ show edit destroy ]

  def index
    @selectable_months = Reservation.order(:date)&.map do |reservation|
      [I18n.l(reservation.date, format: :month_display), I18n.l(reservation.date, format: :month)]
    end.uniq

    @chosen_month = if params[:chosen_month]
        Date.parse("#{params[:chosen_month]}-01")
      else
        Date.current
      end

    # month = params[:month].to_i
    reservation_range = @chosen_month.beginning_of_month..@chosen_month.end_of_month
    @reservations = Reservation.where(date: reservation_range).order(:date, :start_min)
  end

  def show
  end

  def edit
  end

  def update
    reservation = Reservation.find(params[:id])
    ActiveRecord::Base.transaction do
      reserved_date = reservation.date
      reservation.update!(reservation_params)
      updated_date = reservation.date
      ReservationStatus.update_reservation_status!(reserved_date)
      ReservationStatus.update_reservation_status!(updated_date)
    end
    redirect_to admin_reservation_path
  end

  def destroy
    ActiveRecord::Base.transaction do
      deleted_date = @reservation.date
      @reservation.destroy!
      ReservationStatus.update_reservation_status!(deleted_date)
    end
    redirect_to admin_reservations_path(chosen_month: params[:chosen_month]), notice: "Reservation was successfully destroyed."
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:name, :email, :phone_number, :request, :guest_number, :date).merge build_time_param
  end

  def build_time_param
    { start_min: ConvertTime.to_min(params[:reservation][:start_time]) }
  end
end

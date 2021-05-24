class Admin::ReservationsController < Admin::AdminController
  before_action :set_reservation, only: %i[ show edit destroy ]

  def index
    reservation_range = Date.current..(Date.current + 1.month)
    @reservations = Reservation.where(started_at: reservation_range)
  end

  def show
  end

  def edit
  end

  def update
    reservation = Reservation.find(params[:id])
    ActiveRecord::Base.transaction do
      reservation = Reservation.update!(reservation_params)
      reservation_date = reservation.started_at.to_date
      ReservationStatus.update_reservation_status!(reservation_date)
    end
    redirect_to admin_reservation_path
  end

  def destroy
    @reservation.destroy!
    redirect_to admin_reservations_path, notice: "Reservation was successfully destroyed."
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:guest_number, :started_date, :started_time, :name, :email, :phone_number, :request)
  end
end

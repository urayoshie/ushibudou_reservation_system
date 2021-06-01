class Admin::ReservationsController < Admin::AdminController
  before_action :set_reservation, only: %i[ show edit destroy ]

  def index
    reservation_range = Date.current..(Date.current + 1.month)
    @reservations = Reservation.where(start_at: reservation_range).order(:start_at)
  end

  def show
  end

  def edit
  end

  def update
    reservation = Reservation.find(params[:id])
    reserved_date = reservation.start_at.to_date
    ActiveRecord::Base.transaction do
      reservation.update!(reservation_params)
      updated_date = reservation.start_at.to_date
      ReservationStatus.update_reservation_status!(reserved_date)
      ReservationStatus.update_reservation_status!(updated_date)
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
    params.require(:reservation).permit(:guest_number, :name, :email, :phone_number, :request).merge(build_start_at)
  end

  def build_start_at
    { start_at: Time.zone.parse("#{params[:reservation][:started_date]} #{params[:reservation][:started_time]}") }
  end
end

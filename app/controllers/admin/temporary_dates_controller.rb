class Admin::TemporaryDatesController < Admin::AdminController
  before_action :exist_day_condition
  before_action :set_temporary_date, only: [:edit, :update, :destroy]

  def index
    @temporary_dates = TemporaryDate.order(date: :asc).includes(:holiday)
  end

  def new
    @initial_date = DayCondition.initial_date
  end

  def create
    TemporaryDate.transaction do
      date = temporary_date_params[:date]
      temporary_date = TemporaryDate.find_or_initialize_by(date: date)
      temporary_date.assign_attributes(temporary_date_params)
      temporary_date.save!
      ReservationStatus.update_reservation_status!(date)
    end
    redirect_to admin_temporary_dates_path
  end

  def edit
    @initial_date = DayCondition.initial_date
  end

  def update
    TemporaryDate.transaction do
      date = temporary_date_params[:date]
      @temporary_date.assign_attributes(temporary_date_params)
      @temporary_date.save!
      ReservationStatus.update_reservation_status!(date)
    end
    redirect_to admin_temporary_dates_path
  end

  def destroy
    TemporaryDate.transaction do
      date = @temporary_date.date
      @temporary_date.destroy!
      ReservationStatus.update_reservation_status!(date)
    end
    redirect_to admin_temporary_dates_path
  end

  def holiday
    if request.post?
      holidays = Holiday.where("date >= ?", DayCondition.initial_date).order(date: :asc)
      Holiday.transaction do
        holidays.each do |holiday|
          temporary_date = TemporaryDate.find_or_initialize_by(date: holiday.date)
          temporary_date.holiday_id = holiday.id
          temporary_date.assign_attributes(temporary_date_params.slice(:start_min, :end_min))
          temporary_date.save!
        end
      end
      redirect_to admin_temporary_dates_path
    end
  end

  private

  def exist_day_condition
    unless DayCondition.exists?
      redirect_to admin_day_conditions_path, alert: "先に規定の営業・休業日を選択してください"
    end
  end

  def set_temporary_date
    @temporary_date = TemporaryDate.find(params[:id])
  end

  def temporary_date_params
    if params[:temporary_date][:open].nil?
      params.require(:temporary_date).permit(:date)
    else
      params.require(:temporary_date).permit(:date, :start_min, :end_min)
    end
  end
end

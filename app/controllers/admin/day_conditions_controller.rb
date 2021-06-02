class Admin::DayConditionsController < Admin::AdminController
  def index
    @day_conditions = DayCondition.order(:applicable_date, :wday)
  end

  def new
    @days = %w[日 月 火 水 木 金 土]
    if DayCondition.exists?
      # 2回目以降
      today = Date.current
      @day_conditions = DayCondition.order(applicable_date: :asc).group_by { |i| i.wday }
      @day_conditions.each do |wday, day_conditions|
        diff = (wday - today.wday) % 7
        next_occurring_date = today + diff.days
        index = (day_conditions.size - 1) - day_conditions.reverse.find_index { |day_condition| next_occurring_date >= day_condition.applicable_date }
        @day_conditions[wday] = day_conditions[index..]
      end
      render :new
    else
      # 初回
      render :first
    end
  end

  def create
    if DayCondition.exists?
      # 2回目以降
      DayCondition.transaction do
        new_day_condition_params.each do |new_day_condition_param|
          day_condition = DayCondition.find_or_initialize_by(new_day_condition_param.slice(:applicable_date, :wday))
          day_condition.assign_attributes(new_day_condition_param)
          day_condition.save!
        end

        affected_wdays = new_day_condition_params.map { |param| param["wday"].to_i }
        # 変更された曜日の内、applicable_date 以降で、予約が入っている日付の配列
        start_time = params[:applicable_date].to_date.beginning_of_day
        affected_dates = Reservation.select(:start_at).where("start_at >= ?", start_time).map { |reservation| reservation.start_at.to_date }.uniq.select { |date| date.wday.in?(affected_wdays) }

        affected_dates.each do |date|
          ReservationStatus.update_reservation_status!(date)
        end
      end
    else
      # 初回
      DayCondition.create!(first_day_condition_params)
    end
    redirect_to admin_day_conditions_path
  end

  def update
  end

  def destroy
  end

  private

  def first_day_condition_params
    add_param = params.permit(:applicable_date)
    params.require(:day_conditions).map do |param|
      param[:start_min] = param[:end_min] = nil if param[:open].nil?
      param.permit(:wday, :start_min, :end_min).merge add_param
    end
  end

  def new_day_condition_params
    add_param = params.permit(:applicable_date)
    edit_params = params.require(:day_conditions).select { |param| param[:edit].present? }
    edit_params.map do |param|
      param[:start_min] = param[:end_min] = nil if param[:open].nil?
      param.permit(:wday, :start_min, :end_min).merge add_param
    end
  end
end

class Admin::NotificationsController < Admin::AdminController
  before_action :set_notification, only: %i[ show edit update destroy ]

  def index
    @notifications = Notification.order(created_at: :desc)
  end

  def show
  end

  def new
    @notification = Notification.new
  end

  def edit
  end

  def create
    @notification = Notification.new(notification_params)
    if @notification.save
      redirect_to admin_notifications_path, notice: "Notification was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/notifications/1 or /admin/notifications/1.json
  def update
    if @notification.update(notification_params)
      redirect_to admin_notifications_path, notice: "Notification was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/notifications/1 or /admin/notifications/1.json
  def destroy
    @notification.destroy!
    redirect_to admin_notifications_path, notice: "Notification was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def notification_params
      params.require(:notification).permit(:title, :content, :image)
    end
end

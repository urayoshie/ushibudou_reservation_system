class Admin::NotificationsController < Admin::AdminController
  def show
    @notification = Notification.find(params[:id])
  end

  def new
    @notification = Notification.new
  end

  def create
    notification = Notification.create!(notification_params)
    redirect_to admin_notification_path(notification)
  end

  private

  def notification_params
    params.require(:notification).permit(:title, :content)
  end
end

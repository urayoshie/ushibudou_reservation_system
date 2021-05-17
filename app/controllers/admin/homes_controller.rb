class Admin::HomesController < Admin::AdminController
  def index
    @notifications = Notification.order(updated_at: :desc)
  end
end

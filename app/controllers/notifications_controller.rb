class NotificationsController < ApplicationController
  LIMIT = 5

  def index
    @notifications = Notification.order(created_at: :desc).limit(LIMIT)
    render json: @notifications
  end
end

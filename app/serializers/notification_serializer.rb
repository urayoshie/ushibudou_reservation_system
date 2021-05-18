class NotificationSerializer < ActiveModel::Serializer
  attributes :date, :title, :content, :image
  def date
    object.created_at.to_date
  end
end

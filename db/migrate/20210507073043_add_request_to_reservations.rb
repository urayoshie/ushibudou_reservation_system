class AddRequestToReservations < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :request, :text
  end
end

class AddStartMinToReservations < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :start_min, :integer, null: false
    add_column :reservations, :date, :date, null: false
  end
end

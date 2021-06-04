class RemoveStartAtFromReservations < ActiveRecord::Migration[6.1]
  def up
    remove_column :reservations, :start_at, :datetime
  end

  def down
    add_column :reservations, :start_at, :datetime, null: false
  end
end

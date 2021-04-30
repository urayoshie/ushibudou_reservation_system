class RemovePrivateReservationFromReservations < ActiveRecord::Migration[6.1]
  def up
    remove_column :reservations, :private_reservation
  end

  def down
    add_column :reservations, :private_reservation, :boolean, null: false, default: false
  end
end

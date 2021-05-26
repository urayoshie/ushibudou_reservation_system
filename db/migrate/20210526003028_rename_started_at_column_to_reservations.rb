class RenameStartedAtColumnToReservations < ActiveRecord::Migration[6.1]
  def change
    rename_column :reservations, :started_at, :start_at
  end
end

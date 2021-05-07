class CreateReservationStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :reservation_statuses do |t|
      t.integer :minimum_total_num, null: false
      t.date :date, null: false

      t.timestamps
    end
    add_index :reservation_statuses, :date, unique: true
  end
end

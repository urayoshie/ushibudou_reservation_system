class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.integer :guest_number, null: false
      t.datetime :started_at, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number, null: false
      t.boolean :private_reservation, null: false, default: false

      t.timestamps
    end
  end
end

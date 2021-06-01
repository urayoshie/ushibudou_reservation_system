class CreateTemporaryDates < ActiveRecord::Migration[6.1]
  def change
    create_table :temporary_dates do |t|
      t.date :date, null: false
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
    add_index :temporary_dates, :date, unique: true
  end
end

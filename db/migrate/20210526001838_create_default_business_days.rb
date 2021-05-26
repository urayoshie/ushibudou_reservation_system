class CreateDefaultBusinessDays < ActiveRecord::Migration[6.1]
  def change
    create_table :default_business_days do |t|
      t.date :applicable_date, null: false
      t.integer :wday, null: false
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end

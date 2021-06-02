class AddDateAndWdayIndexToDayConditions < ActiveRecord::Migration[6.1]
  def change
    add_index :day_conditions, [:applicable_date, :wday], unique: true
  end
end

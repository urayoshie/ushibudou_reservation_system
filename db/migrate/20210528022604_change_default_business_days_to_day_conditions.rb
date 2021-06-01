class ChangeDefaultBusinessDaysToDayConditions < ActiveRecord::Migration[6.1]
  def change
    rename_table :default_business_days, :day_conditions
  end
end

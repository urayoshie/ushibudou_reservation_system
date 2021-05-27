class ChangeDatatypeStartAtOfDefaultBusinessDays < ActiveRecord::Migration[6.1]
  def up
    change_column :default_business_days, :start_at, :integer
    change_column :default_business_days, :end_at, :integer
  end

  def down
    change_column :default_business_days, :start_at, :datetime
    change_column :default_business_days, :end_at, :datetime
  end
end

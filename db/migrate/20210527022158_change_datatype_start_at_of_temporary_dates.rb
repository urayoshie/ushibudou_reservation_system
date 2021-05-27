class ChangeDatatypeStartAtOfTemporaryDates < ActiveRecord::Migration[6.1]
  def up
    change_column :temporary_dates, :start_at, :integer
    change_column :temporary_dates, :end_at, :integer
  end

  def down
    change_column :temporary_dates, :start_at, :datetime
    change_column :temporary_dates, :end_at, :datetime
  end
end

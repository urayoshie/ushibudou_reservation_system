class RenameStartAtColumnToTemporaryDates < ActiveRecord::Migration[6.1]
  def change
    rename_column :temporary_dates, :start_at, :start_min
    rename_column :temporary_dates, :end_at, :end_min
  end
end

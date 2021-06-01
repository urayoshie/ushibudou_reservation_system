class RenameStartAtColumnToDefaultBusinessDays < ActiveRecord::Migration[6.1]
  def change
    rename_column :default_business_days, :start_at, :start_min
    rename_column :default_business_days, :end_at, :end_min
  end
end

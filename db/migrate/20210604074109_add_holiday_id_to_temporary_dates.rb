class AddHolidayIdToTemporaryDates < ActiveRecord::Migration[6.1]
  def change
    add_reference :temporary_dates, :holiday, foreign_key: true
  end
end

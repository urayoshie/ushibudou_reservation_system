require "csv"

namespace :holiday do
  desc "内閣府のCSVファイルをインポート"
  task import_csv: :environment do
    URI.open("https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv") do |file|
      list = CSV.read(file, encoding: "SJIS")
      index = list.find_index { |row| row.first =~ /\A2020/ }
      # 2020年以降のみに制限
      list = list[index..-1]
      list.each do |row|
        holiday = Holiday.find_or_initialize_by(date: row[0])
        holiday.name = row[1]
        holiday.save!
      end
      if list.size != Holiday.count
        diff_dates = Holiday.pluck(:date) - list.map { |row| Date.parse(row.first) }
        OutputLog.error(
          diff_dates: diff_dates.map(&:to_s).join(", "),
          message: "祝日が変更もしくは削除されています。",
        )
      end
    end
  end
end

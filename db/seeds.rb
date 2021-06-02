# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "date"
require "csv"

%w[reservations reservation_statuses menus day_conditions temporary_dates].each do |table_name|
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
end

# date_range = Date.current..(Date.current + 10.months)
# reservation_params = date_range.map do |date|
#   year, month, day = date.year, date.month, date.day
#   hour = rand(15..24)
#   min = [0, 15, 30, 45].sample
#   date_time = Time.local(year, month, day, 0, min) + hour.hours
#   guest_num = rand(1..12)

#   {
#     start_at: date_time,
#     guest_number: guest_num,
#     name: "tarou yamada",
#     email: "hoge@example.com",
#     phone_number: "09099999999",
#   }
# end

# day_conditions
date4 = Date.new(2021, 4, 20)
DayCondition.create!(applicable_date: date4, wday: 3, start_min: nil, end_min: nil)

date = Date.new(2021, 5, 26)
DayCondition.create!(applicable_date: date, wday: 0, start_min: 900, end_min: 1500)
DayCondition.create!(applicable_date: date, wday: 1, start_min: 900, end_min: 1500)
DayCondition.create!(applicable_date: date, wday: 2, start_min: nil, end_min: nil)
DayCondition.create!(applicable_date: date, wday: 3, start_min: 900, end_min: 1500)
DayCondition.create!(applicable_date: date, wday: 4, start_min: 900, end_min: 1500)
DayCondition.create!(applicable_date: date, wday: 5, start_min: 900, end_min: 1500)
DayCondition.create!(applicable_date: date, wday: 6, start_min: 900, end_min: 1500)

date2 = Date.new(2021, 6, 23)
DayCondition.create!(applicable_date: date2, wday: 0, start_min: 900, end_min: 1200)
DayCondition.create!(applicable_date: date2, wday: 3, start_min: nil, end_min: nil)

date3 = Date.new(2021, 7, 21)
DayCondition.create!(applicable_date: date3, wday: 3, start_min: 900, end_min: 1200)

# date4 = Date.new(2021, 7, 1)
# DayCondition.create!(applicable_date: date4, wday: 3, start_min: 900, end_min: 1200)

# temporary_dates
# 臨時営業日
TemporaryDate.create!(date: Date.new(2021, 6, 2), start_min: 660, end_min: 1500)
TemporaryDate.create!(date: Date.new(2021, 6, 25), start_min: 690, end_min: 1500)
TemporaryDate.create!(date: Date.new(2021, 8, 10), start_min: 690, end_min: 1500)
# 臨時休業日
TemporaryDate.create!(date: Date.new(2021, 8, 13), start_min: nil, end_min: nil)
TemporaryDate.create!(date: Date.new(2021, 8, 14), start_min: nil, end_min: nil)
TemporaryDate.create!(date: Date.new(2021, 8, 15), start_min: nil, end_min: nil)

puts "デフォルトの営業日データを投入しました。"

reservation_params = [
  # 一般予約のみ(6月2日)
  { start_at: "2021-06-02 15:00:00", guest_number: 1 },
  { start_at: "2021-06-02 15:15:00", guest_number: 2 },
  { start_at: "2021-06-02 15:30:00", guest_number: 3 },
  { start_at: "2021-06-02 15:45:00", guest_number: 4 },
  { start_at: "2021-06-02 16:00:00", guest_number: 2 },
  { start_at: "2021-06-02 17:15:00", guest_number: 3 },
  { start_at: "2021-06-02 17:45:00", guest_number: 2 },
  { start_at: "2021-06-02 18:00:00", guest_number: 4 },
  { start_at: "2021-06-02 19:15:00", guest_number: 1 },
  { start_at: "2021-06-02 19:30:00", guest_number: 2 },
  { start_at: "2021-06-02 19:45:00", guest_number: 2 },
  { start_at: "2021-06-02 20:00:00", guest_number: 4 },
  { start_at: "2021-06-02 21:30:00", guest_number: 3 },
  { start_at: "2021-06-02 21:45:00", guest_number: 1 },
  { start_at: "2021-06-02 22:00:00", guest_number: 1 },
  { start_at: "2021-06-02 23:00:00", guest_number: 4 },
  # 貸切予約がある場合(6月3日)
  { start_at: "2021-06-03 17:00:00", guest_number: 4 },
  { start_at: "2021-06-03 17:30:00", guest_number: 4 },
  { start_at: "2021-06-03 18:00:00", guest_number: 4 },
  { start_at: "2021-06-03 20:00:00", guest_number: 1 },
  { start_at: "2021-06-03 20:30:00", guest_number: 4 },
  { start_at: "2021-06-03 21:00:00", guest_number: 2 },
  { start_at: "2021-06-03 23:00:00", guest_number: 6 },
  # 予約多くて予約日として選択できないケース(6月4日)
  { start_at: "2021-06-04 15:00:00", guest_number: 6 },
  { start_at: "2021-06-04 17:00:00", guest_number: 4 },
  { start_at: "2021-06-04 17:30:00", guest_number: 4 },
  { start_at: "2021-06-04 18:00:00", guest_number: 4 },
  { start_at: "2021-06-04 19:00:00", guest_number: 2 },
  { start_at: "2021-06-04 19:30:00", guest_number: 3 },
  { start_at: "2021-06-04 20:00:00", guest_number: 1 },
  { start_at: "2021-06-04 20:15:00", guest_number: 2 },
  { start_at: "2021-06-04 20:30:00", guest_number: 4 },
  { start_at: "2021-06-04 21:00:00", guest_number: 2 },
  { start_at: "2021-06-04 23:00:00", guest_number: 8 },
  # 予約人数選択後、予約日を選択し、予約人数を変更した時に選べる人数と選べない人数が出るケース(6月5日)
  { start_at: "2021-06-05 15:00:00", guest_number: 4 },
  { start_at: "2021-06-05 15:30:00", guest_number: 4 },
  { start_at: "2021-06-05 17:00:00", guest_number: 5 },
  { start_at: "2021-06-05 19:30:00", guest_number: 1 },
  { start_at: "2021-06-05 21:00:00", guest_number: 2 },
  { start_at: "2021-06-05 21:30:00", guest_number: 5 },
  { start_at: "2021-06-05 22:00:00", guest_number: 2 },
  { start_at: "2021-06-05 23:00:00", guest_number: 2 },
  # 貸切予約がある場合(6月20日)
  { start_at: "2021-06-20 17:00:00", guest_number: 4 },
  { start_at: "2021-06-20 17:30:00", guest_number: 4 },
  { start_at: "2021-06-20 18:00:00", guest_number: 4 },
  { start_at: "2021-06-20 20:00:00", guest_number: 1 },
  { start_at: "2021-06-20 20:30:00", guest_number: 4 },
  { start_at: "2021-06-20 21:00:00", guest_number: 2 },
  { start_at: "2021-06-20 23:00:00", guest_number: 6 },
  # 予約多くて予約日として選択できないケース(6月21日)
  { start_at: "2021-06-21 15:00:00", guest_number: 6 },
  { start_at: "2021-06-21 17:00:00", guest_number: 4 },
  { start_at: "2021-06-21 17:30:00", guest_number: 4 },
  { start_at: "2021-06-21 18:00:00", guest_number: 4 },
  { start_at: "2021-06-21 19:00:00", guest_number: 2 },
  { start_at: "2021-06-21 19:30:00", guest_number: 3 },
  { start_at: "2021-06-21 20:00:00", guest_number: 1 },
  { start_at: "2021-06-21 20:15:00", guest_number: 2 },
  { start_at: "2021-06-21 20:30:00", guest_number: 4 },
  { start_at: "2021-06-21 21:00:00", guest_number: 2 },
  { start_at: "2021-06-21 23:00:00", guest_number: 8 },
  # 予約人数選択後、予約日を選択し、予約人数を変更した時に選べる人数と選べない人数が出るケース(6月22日)
  { start_at: "2021-06-24 15:00:00", guest_number: 4 },
  { start_at: "2021-06-24 15:30:00", guest_number: 4 },
  { start_at: "2021-06-24 17:00:00", guest_number: 5 },
  { start_at: "2021-06-24 19:30:00", guest_number: 1 },
  { start_at: "2021-06-24 21:00:00", guest_number: 2 },
  { start_at: "2021-06-24 21:30:00", guest_number: 5 },
  { start_at: "2021-06-24 22:00:00", guest_number: 2 },
  { start_at: "2021-06-24 23:00:00", guest_number: 2 },
]

reservation_params.map! do |reservation|
  # {
  #   start_at: reservation[:start_at],
  #   guest_number: reservation[:guest_number],
  #   name: "tarou yamada",
  #   email: "hoge@example.com",
  #   phone_number: "09099999999",
  # }
  reservation.merge(
    name: "tarou yamada",
    email: "hoge@example.com",
    phone_number: "09099999999",
  )
end

Reservation.create!(reservation_params)

puts "予約のインポートに成功しました！"

ADMIN_EMAIL = "admin@example.com"
PASSWORD = "password"

AdminUser.find_or_create_by!(email: ADMIN_EMAIL) do |admin_user|
  admin_user.password = PASSWORD
  puts "管理者ユーザーの初期データインポートに成功しました。"
end

CSV.foreach("db/csv_data/menu.csv", headers: true) do |row|
  Menu.create!(row)
end
puts "メニューのインポートに成功しました！"

# reservation_statuses テーブルを最新の状態に更新
system("rails reservation:update_reservation_status")

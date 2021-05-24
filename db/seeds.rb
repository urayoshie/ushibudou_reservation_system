# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "csv"

%w[reservations reservation_statuses menus].each do |table_name|
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
#     started_at: date_time,
#     guest_number: guest_num,
#     name: "tarou yamada",
#     email: "hoge@example.com",
#     phone_number: "09099999999",
#   }
# end

reservation_params = [
  # 一般予約のみ(6月2日)
  { started_at: "2021-06-02 15:00:00", guest_number: 1 },
  { started_at: "2021-06-02 15:15:00", guest_number: 2 },
  { started_at: "2021-06-02 15:30:00", guest_number: 3 },
  { started_at: "2021-06-02 15:45:00", guest_number: 4 },
  { started_at: "2021-06-02 16:00:00", guest_number: 2 },
  { started_at: "2021-06-02 17:15:00", guest_number: 3 },
  { started_at: "2021-06-02 17:45:00", guest_number: 2 },
  { started_at: "2021-06-02 18:00:00", guest_number: 4 },
  { started_at: "2021-06-02 19:15:00", guest_number: 1 },
  { started_at: "2021-06-02 19:30:00", guest_number: 2 },
  { started_at: "2021-06-02 19:45:00", guest_number: 2 },
  { started_at: "2021-06-02 20:00:00", guest_number: 4 },
  { started_at: "2021-06-02 21:30:00", guest_number: 3 },
  { started_at: "2021-06-02 21:45:00", guest_number: 1 },
  { started_at: "2021-06-02 22:00:00", guest_number: 1 },
  { started_at: "2021-06-02 23:00:00", guest_number: 4 },
  # 貸切予約がある場合(6月3日)
  { started_at: "2021-06-03 17:00:00", guest_number: 4 },
  { started_at: "2021-06-03 17:30:00", guest_number: 4 },
  { started_at: "2021-06-03 18:00:00", guest_number: 4 },
  { started_at: "2021-06-03 20:00:00", guest_number: 1 },
  { started_at: "2021-06-03 20:30:00", guest_number: 4 },
  { started_at: "2021-06-03 21:00:00", guest_number: 2 },
  { started_at: "2021-06-03 23:00:00", guest_number: 6 },
  # 予約多くて予約日として選択できないケース(6月4日)
  { started_at: "2021-06-04 15:00:00", guest_number: 6 },
  { started_at: "2021-06-04 17:00:00", guest_number: 4 },
  { started_at: "2021-06-04 17:30:00", guest_number: 4 },
  { started_at: "2021-06-04 18:00:00", guest_number: 4 },
  { started_at: "2021-06-04 19:00:00", guest_number: 2 },
  { started_at: "2021-06-04 19:30:00", guest_number: 3 },
  { started_at: "2021-06-04 20:00:00", guest_number: 1 },
  { started_at: "2021-06-04 20:15:00", guest_number: 2 },
  { started_at: "2021-06-04 20:30:00", guest_number: 4 },
  { started_at: "2021-06-04 21:00:00", guest_number: 2 },
  { started_at: "2021-06-04 23:00:00", guest_number: 8 },
  # 予約人数選択後、予約日を選択し、予約人数を変更した時に選べる人数と選べない人数が出るケース(6月5日)
  { started_at: "2021-06-05 15:00:00", guest_number: 4 },
  { started_at: "2021-06-05 15:30:00", guest_number: 4 },
  { started_at: "2021-06-05 17:00:00", guest_number: 5 },
  { started_at: "2021-06-05 19:30:00", guest_number: 1 },
  { started_at: "2021-06-05 21:00:00", guest_number: 2 },
  { started_at: "2021-06-05 21:30:00", guest_number: 5 },
  { started_at: "2021-06-05 22:00:00", guest_number: 2 },
  { started_at: "2021-06-05 23:00:00", guest_number: 2 },
  # 貸切予約がある場合(6月20日)
  { started_at: "2021-06-20 17:00:00", guest_number: 4 },
  { started_at: "2021-06-20 17:30:00", guest_number: 4 },
  { started_at: "2021-06-20 18:00:00", guest_number: 4 },
  { started_at: "2021-06-20 20:00:00", guest_number: 1 },
  { started_at: "2021-06-20 20:30:00", guest_number: 4 },
  { started_at: "2021-06-20 21:00:00", guest_number: 2 },
  { started_at: "2021-06-20 23:00:00", guest_number: 6 },
  # 予約多くて予約日として選択できないケース(6月21日)
  { started_at: "2021-06-21 15:00:00", guest_number: 6 },
  { started_at: "2021-06-21 17:00:00", guest_number: 4 },
  { started_at: "2021-06-21 17:30:00", guest_number: 4 },
  { started_at: "2021-06-21 18:00:00", guest_number: 4 },
  { started_at: "2021-06-21 19:00:00", guest_number: 2 },
  { started_at: "2021-06-21 19:30:00", guest_number: 3 },
  { started_at: "2021-06-21 20:00:00", guest_number: 1 },
  { started_at: "2021-06-21 20:15:00", guest_number: 2 },
  { started_at: "2021-06-21 20:30:00", guest_number: 4 },
  { started_at: "2021-06-21 21:00:00", guest_number: 2 },
  { started_at: "2021-06-21 23:00:00", guest_number: 8 },
  # 予約人数選択後、予約日を選択し、予約人数を変更した時に選べる人数と選べない人数が出るケース(6月22日)
  { started_at: "2021-06-22 15:00:00", guest_number: 4 },
  { started_at: "2021-06-22 15:30:00", guest_number: 4 },
  { started_at: "2021-06-22 17:00:00", guest_number: 5 },
  { started_at: "2021-06-22 19:30:00", guest_number: 1 },
  { started_at: "2021-06-22 21:00:00", guest_number: 2 },
  { started_at: "2021-06-22 21:30:00", guest_number: 5 },
  { started_at: "2021-06-22 22:00:00", guest_number: 2 },
  { started_at: "2021-06-22 23:00:00", guest_number: 2 },
]

reservation_params.map! do |reservation|
  # {
  #   started_at: reservation[:started_at],
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

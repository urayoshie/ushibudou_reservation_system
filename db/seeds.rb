# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Reservation.delete_all

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
  # 一般予約のみ(5月1日)
  { started_at: "2021-05-01 15:00:00", guest_number: 1 },
  { started_at: "2021-05-01 15:15:00", guest_number: 2 },
  { started_at: "2021-05-01 15:30:00", guest_number: 3 },
  { started_at: "2021-05-01 15:45:00", guest_number: 4 },
  { started_at: "2021-05-01 16:00:00", guest_number: 2 },
  { started_at: "2021-05-01 17:15:00", guest_number: 3 },
  { started_at: "2021-05-01 17:45:00", guest_number: 2 },
  { started_at: "2021-05-01 18:00:00", guest_number: 4 },
  { started_at: "2021-05-01 19:15:00", guest_number: 1 },
  { started_at: "2021-05-01 19:30:00", guest_number: 2 },
  { started_at: "2021-05-01 19:45:00", guest_number: 2 },
  { started_at: "2021-05-01 20:00:00", guest_number: 4 },
  { started_at: "2021-05-01 21:30:00", guest_number: 3 },
  { started_at: "2021-05-01 21:45:00", guest_number: 1 },
  { started_at: "2021-05-01 22:00:00", guest_number: 1 },
  { started_at: "2021-05-01 23:00:00", guest_number: 4 },
  # 貸切予約がある場合(5月2日)
  { started_at: "2021-05-02 15:00:00", guest_number: 6, private_reservation: true },
  { started_at: "2021-05-02 17:00:00", guest_number: 4 },
  { started_at: "2021-05-02 17:30:00", guest_number: 4 },
  { started_at: "2021-05-02 18:00:00", guest_number: 4 },
  { started_at: "2021-05-02 19:00:00", guest_number: 2 },
  { started_at: "2021-05-02 19:30:00", guest_number: 3 },
  { started_at: "2021-05-02 20:00:00", guest_number: 1 },
  { started_at: "2021-05-02 20:15:00", guest_number: 2 },
  { started_at: "2021-05-02 20:30:00", guest_number: 4 },
  { started_at: "2021-05-02 21:00:00", guest_number: 2 },
  { started_at: "2021-05-02 23:00:00", guest_number: 8, private_reservation: true },
  # 貸切予約がある場合(5月3日)
  { started_at: "2021-05-03 17:00:00", guest_number: 4 },
  { started_at: "2021-05-03 17:30:00", guest_number: 4 },
  { started_at: "2021-05-03 18:00:00", guest_number: 4 },
  { started_at: "2021-05-03 20:00:00", guest_number: 1 },
  { started_at: "2021-05-03 20:30:00", guest_number: 4 },
  { started_at: "2021-05-03 21:00:00", guest_number: 2 },
  { started_at: "2021-05-03 23:00:00", guest_number: 12, private_reservation: true },
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

puts "インポートに成功しました！"

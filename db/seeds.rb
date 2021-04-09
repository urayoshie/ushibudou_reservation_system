# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Reservation.delete_all

date_range = Date.current..(Date.current + 10.months)
reservation_params = date_range.map do |date|
  year, month, day = date.year, date.month, date.day
  hour = rand(15..24)
  min = [0, 15, 30, 45].sample
  date_time = Time.local(year, month, day, 0, min) + hour.hours
  guest_num = rand(1..12)

  {
    started_at: date_time,
    guest_number: guest_num,
    name: "tarou yamada",
    email: "hoge@example.com",
    phone_number: "09099999999",
  }
end

Reservation.create!(reservation_params)

puts "インポートに成功しました！"

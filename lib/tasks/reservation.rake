namespace :reservation do
  desc "reservation_statusesテーブルを最新状態に更新"
  task update_reservation_status: :environment do
    # 予約されている日付の配列を作成
    date_list = Reservation.distinct.pluck(:date)
    # 各予約日について、予約の状態を reservation_statusesテーブル に反映
    date_list.each do |date|
      ReservationStatus.update_reservation_status!(date)
    end
    puts "reservation_statusesテーブルを最新状態に更新しました。"
  end
end

class ReservationStatus < ApplicationRecord
    # 基本的なバリデーションは入れる
    # 日付 YYYY-MM-DD
    VALID_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/
    validates :minimum_total_num, presence: true, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: 12}
    validates :date, presence: true, uniqueness: true  #, :format {with: VALID_DATE_REGEX}

end

class Holiday < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :name, presence: true
  has_many :temporary_dates, dependent: :nullify
end

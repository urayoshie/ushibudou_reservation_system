class TemporaryDate < ApplicationRecord
  validates :date, uniqueness: true
end

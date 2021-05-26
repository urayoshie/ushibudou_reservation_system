class DefaultBusinessDay < ApplicationRecord
  validates :wday, presence: true, numericality: { in: 0..6 }
end

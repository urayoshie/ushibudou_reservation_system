class Menu < ApplicationRecord
  acts_as_list

  validates :genre, presence: true
  validates :name, presence: true
  validates :price, presence: true

  enum genre: {
    meat: 0,
    innards: 1,
    appetizer: 2,
    others: 3,
    main: 4,
    drink: 5,
  }
end

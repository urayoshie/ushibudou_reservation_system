class ReservationsController < ApplicationController
  def index
    @available_days = [
      "2021-04-14",
      "2021-04-24",
    ]
  end
end

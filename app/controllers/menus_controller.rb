class MenusController < ApplicationController
  def index
    menus = Menu.select(:genre, :name, :price).order(position: :asc)
    json = menus.group_by(&:genre).transform_values do |val|
      data = val.map do |menu|
        { name: menu.name, price: menu.price }
      end
      {
        genre: val[0].genre_i18n,
        data: data,
      }
    end
    # menus = @menus.group_by(&:genre)
    render json: json
  end

end

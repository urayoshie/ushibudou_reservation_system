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

  def update
    menu = Menu.find_by(position: params[:id], name: params[:name])
    new_menu = Menu.find_by(position: params[:new_index])
    binding.pry
    if menu.nil? || new_menu.nil?
      render json: { error: "データに異常が発生しておりますのでリロードします。" }, status: :bad_resuest
    elsif menu.genre == new_menu.genre
      menu.update!(position: params[:new_index])
      render json: nil, status: :no_content
    else
      render json: { error: "同じジャンル間で移動して下さい。リロードします。" }, status: :bad_resuest
    end
  end
end

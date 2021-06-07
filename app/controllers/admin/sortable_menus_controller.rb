class Admin::SortableMenusController < Admin::AdminController
  def update
    menu = Menu.find_by(position: params[:id], name: params[:name])
    new_menu = Menu.find_by(position: params[:new_index])
    if menu.nil? || new_menu.nil?
      render json: { error: "データに異常が発生しておりますのでリロードします。" }, status: :bad_request
    elsif menu.genre == new_menu.genre
      menu.update!(position: params[:new_index])
      render json: { oldIndex: params[:id], newIndex: params[:new_index] }
    else
      render json: { error: "同じジャンル間で移動して下さい。リロードします。" }, status: :bad_request
    end
  end
end

class Admin::MenusController < Admin::AdminController
  before_action :set_menu, only: %i[ show edit update destroy ]

  def index
    @menus = Menu.order(position: :asc)
  end

  def show
  end

  def new
    @menu = Menu.new
  end

  def edit
  end

  def create
    @menu = Menu.new(menu_params)
    Menu.transaction do
      @menu.save!
      Menu.sort_position!
    end
    redirect_to admin_menus_path, notice: "メニューを作成しました"
  end

  # PATCH/PUT /admin/menus/1 or /admin/menus/1.json
  def update
    Menu.transaction do
      @menu.update!(menu_params)
      Menu.sort_position!
    end
    redirect_to admin_menus_path, notice: "メニューを更新しました。"
  end

  # DELETE /admin/menus/1 or /admin/menus/1.json
  def destroy
    Menu.transaction do
      @menu.destroy!
      Menu.sort_position!
    end
    redirect_to admin_menus_path, notice: "メニューを削除しました。"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_menu
    @menu = Menu.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def menu_params
    params.require(:menu).permit(:genre, :name, :price)
  end
end

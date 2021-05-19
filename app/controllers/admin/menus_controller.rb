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
    if @menu.save
      redirect_to admin_menus_path, notice: "Menu was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/menus/1 or /admin/menus/1.json
  def update
    if @menu.update(menu_params)
      redirect_to admin_menus_path, notice: "Menu was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/menus/1 or /admin/menus/1.json
  def destroy
    @menu.destroy!
    redirect_to admin_menus_path, notice: "Menu was successfully destroyed."
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

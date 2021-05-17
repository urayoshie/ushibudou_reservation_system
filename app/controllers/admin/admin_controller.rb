class Admin::AdminController < ApplicationController
  layout "admin/layouts/admin.html.erb"
  before_action :authenticate_admin_user!
end
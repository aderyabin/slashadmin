module SlashAdmin
  class DashboardController < SlashAdminController
    def index
      respond_to do |format|
        format.html { render "admin/dashboard", :layout => "admin" }
      end
    end
  end
end
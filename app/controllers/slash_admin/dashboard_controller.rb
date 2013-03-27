module SlashAdmin
  class DashboardController < ApplicationController
    helper :all
    
    def index
      respond_to do |format|
        format.html { render "admin/dashboard", :layout => "admin" }
      end
    end
  end
end
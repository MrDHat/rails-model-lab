module Newsroom
  class DashboardController < BaseController
    def show
      @dashboard = NewsroomDashboard.new
    end
  end
end

class HomeController < ApplicationController
  def show
    @front = FrontPage.new
  end
end

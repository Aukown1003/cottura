class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!

  def top
    @reports = Report.with_user_and_recipe
  end

end

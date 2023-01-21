class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!

  def top
    @reports = Report.all.includes(:user, recipe: :user)
  end

end

class Public::ReportsController < ApplicationController
  def new
    @report = Report.new
    @recipe = Recipe.find(params[:recipe_id])
  end

  def create
    @report = current_user.reports.new(report_params)

  end

  private
  def report_params
    params.require(:report).permit(:user_id, :recipe_id, :content)
  end
end

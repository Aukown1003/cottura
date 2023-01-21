class Public::ReportsController < ApplicationController
  def new
    @report = Report.new
    @recipe = Recipe.find(params[:id])
  end

  def create
    @report = current_user.reports.new(report_params)
    if @report.save
      redirect_to root_path, notice: "報告を行いました"
    else
      @recipe = Recipe.find(params[:recipe_id])
      render :new
    end
  end

  private
  def report_params
    params.require(:report).permit(:user_id, :recipe_id, :content)
  end
end

class Admin::ReportsController < ApplicationController
  before_action :authenticate_admin!
  def show
    @report = Report.with_user_and_recipe.find(params[:id])
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy!
    redirect_to admin_root_path, notice: '報告を削除しました'
  end
end
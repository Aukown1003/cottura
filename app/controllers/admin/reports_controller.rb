class Admin::ReportsController < ApplicationController

  def show
    @report = Report.includes(:user, recipe: :user).find(params[:id])
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    redirect_to admin_root_path, notice: '報告を削除しました'
  end
end

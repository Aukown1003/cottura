class Admin::ReportsController < ApplicationController
  before_action :authenticate_admin!
  def show
    @report = Report.includes(:user, recipe: :user).find(params[:id])
  end

  def destroy
    @report = Report.find(params[:id])
    if @report.destroy
      redirect_to admin_root_path, notice: '報告を削除しました'
    else
      redirect_to admin_root_path, alert: '報告を削除に失敗しました'
    end
  end
end

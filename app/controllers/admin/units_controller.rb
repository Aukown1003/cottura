class Admin::UnitsController < ApplicationController
  
  def index
    @units = Unit.all.includes(:recipe_ingredients)
    @unit = Unit.new
  end
  
  def create
    @unit = Unit.new(params_unit)
    if @unit.save
      redirect_to admin_units_index_path, notice: '単位を作成しました'
    else
      redirect_to admin_units_index_path, alert: '単位の作成に失敗しました'
    end
  end

  def edit
    @unit = Unit.find(params[:id])
  end
  
  def update
    @unit = Unit.find(params[:id])
    if @unit.update(params_unit)
      redirect_to admin_units_index_path, notice: '単位を変更しました'
    else
      redirect_to admin_units_index_path, alert: '単位の変更に失敗しました'
    end
  end
  
  def destroy
    @unit = Unit.find(params[:id])
    if @unit.destroy
      redirect_to admin_units_index_path, notice: '単位を削除しました'
    else
      redirect_to admin_units_index_path, alert: '単位の削除に失敗しました'
    end
  end
  
  private
  def params_unit
    params.require(:unit).permit(:name)
  end
end

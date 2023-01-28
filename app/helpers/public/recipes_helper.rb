module Public::RecipesHelper
  # 検索用時間表示メソッド
  def view_search_data(time)
    hour_min = 60
    time = time.to_i
    if time < hour_min
      time = "#{time}分以内"
    elsif time % hour_min == 0
      hour =  time / hour_min
      time = "#{hour}時間以内"
    else
      hour = time / hour_min
      min = time % hour_min
      time = "#{hour}時間" + "#{min}分以内"
    end
    return time
  end

  # レシピ用時間表示メソッド 
  def view_time_data(time)
    hour_min = 60
    if time < hour_min
      time = "#{time}分"
    elsif data % hour_min == 0
      hour =  time / hour_min
      time = "#{hour}時間"
    else
      hour = time / hour_min
      min = time % hour_min
      time = "#{hour}時間" + "#{min}分"
    end
    return time
  end
  
  def review_average(score)
    score.average(:score).to_f.round(1)
  end


  def material_quantity_after_conversion(quantity)
    number_with_precision((BigDecimal(quantity.to_s) * session[:recalculation]).round(1), precision: 1, strip_insignificant_zeros: true)
  end
    
  def material_quantity(quantity)
    number_with_precision(quantity, precision: 1, strip_insignificant_zeros: true)
  end

end

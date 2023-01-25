module Public::RecipesHelper
 # 時間表示メソッド
  def view_search_data(data)
    hour_min = 60
    data = data.to_i
    if data < hour_min
      data = "#{data}分以内"
    elsif data % hour_min == 0
      hour =  data / hour_min
      data = "#{hour}時間以内"
    else
      hour = data / hour_min
      min = data % hour_min
      data = "#{hour}時間" + "#{min}分以内"
    end
    return data
  end
end

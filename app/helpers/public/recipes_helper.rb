module Public::RecipesHelper
  
  # レシピ写真ヘルパー
  def recipe_image(recipe)
    if recipe.image.attached?
      image_tag recipe.get_recipe_image(480, 480), class: "img-fluid"
    else
      image_tag 'no_image_item.png', class: "img-fluid default-image"
    end
  end

  # 作り方写真ヘルパー
  def step_image(form, recipe)
    if current_page?(new_recipe_path)
      image_tag 'no_image_item.png', class: "img-fluid default-image"
    else
      if form.options[:child_index] + 1 > recipe.recipe_steps.count
        image_tag 'no_image_item.png', class: "img-fluid default-image"
      else
        image_tag form.object.get_recipe_step_image(90,90)
      end
    end
  end
  
  # 検索用時間表示ヘルパー
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

  # レシピ用時間表示ヘルパー
  def view_time_data(time)
    hour_min = 60
    if time < hour_min
      time = "#{time}分"
    elsif time % hour_min == 0
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
  
  # ジャンルの表示メソッド
  def genre_select(form, recipe)
    if recipe.category.present?
      form.collection_select(:genre_id, @genre, :id, :name, {}, selected: recipe.category.genre )
    else
      form.collection_select(:genre_id, @genre, :id, :name, include_blank: "ジャンルを選択してください")
    end
  end
  
  # カテゴリーの表示メソッド
  def category_select(form, recipe)
    if recipe.category.present?
      form.collection_select(:category_id, @category.all, :id, :name, {include_blank: "ジャンルを選択後、選択可能になります"}, selected: recipe.category )
    else
      form.collection_select(:category_id, @category.all, :id, :name, {include_blank: "ジャンルを選択後、選択可能になります"}, disabled: true )
    end
  end

  # レシピの再計算ヘルパー(再計算した場合)
  def material_quantity_after_conversion(quantity)
    number_with_precision((BigDecimal(quantity.to_s) * session[:recalculation]).round(1), precision: 1, strip_insignificant_zeros: true)
  end
  
  # レシピの再計算ヘルパー(再計算しない場合)  
  def material_quantity(quantity)
    number_with_precision(quantity, precision: 1, strip_insignificant_zeros: true)
  end
  
  # レシピの再計算ヘルパー(上記２項目統合)
  def ingredient_quantity(ingredient)
    session[:recalculation].present? ? material_quantity_after_conversion(ingredient.quantity) : material_quantity(ingredient.quantity)
  end
  
  # レシピの分量の分数表示
  def convert_rational(ingredient)
    float_num = BigDecimal(ingredient.to_s) - BigDecimal((ingredient.to_i).to_s)
    rational_num = Rational(float_num).rationalize(Rational('0.01'))
    if rational_num.to_f == 0.0
      ingredient
    elsif ingredient.to_i == 0
      rational_num.to_s
    else
      "#{ingredient.to_i}と" + rational_num.to_s
    end
  end
end

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
  
  # 時間表示ヘルパー
  def view_time_data(time, suffix = "")
    hour_min = 60
    time = time.to_i
    if time < hour_min
      time = "#{time}分#{suffix}"
    elsif time % hour_min == 0
      hour =  time / hour_min
      time = "#{hour}時間#{suffix}"
    else
      hour = time / hour_min
      min = time % hour_min
      time = "#{hour}時間" + "#{min}分#{suffix}"
    end
    return time
  end
  
  # レビューの平均スコア
  def review_average(score)
    score.average(:score).to_f.round(1)
  end
  
  # ジャンルの表示
  def genre_select(form, recipe)
    if recipe.category.present?
      form.collection_select(:genre_id, @genre, :id, :name, {}, selected: recipe.category.genre )
    else
      form.collection_select(:genre_id, @genre, :id, :name, include_blank: "ジャンルを選択してください")
    end
  end
  
  # カテゴリーの表示
  def category_select(form, recipe)
    if recipe.category.present?
      form.collection_select(:category_id, @category.all, :id, :name, {include_blank: "ジャンルを選択後、選択可能になります"}, selected: recipe.category )
    else
      form.collection_select(:category_id, @category.all, :id, :name, {include_blank: "ジャンルを選択後、選択可能になります"}, disabled: true )
    end
  end

  # レシピの再計算(再計算した場合)
  def material_quantity_after_conversion(quantity)
    number_with_precision((BigDecimal(quantity.to_s) * session[:recalculation]).round(1), precision: 1, strip_insignificant_zeros: true)
  end
  
  # レシピの再計算(再計算しない場合)  
  def material_quantity(quantity)
    number_with_precision(quantity, precision: 1, strip_insignificant_zeros: true)
  end
  
  # レシピの再計算(上記２項目統合)
  def ingredient_quantity(ingredient)
    session[:recalculation].present? ? material_quantity_after_conversion(ingredient.quantity) : material_quantity(ingredient.quantity)
  end
  
  # 大さじか小さじの場合
  def teaspoon_or_tablespoon?(ingredient)
    ingredient.unit.name == "大さじ" || ingredient.unit.name == "小さじ"
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
  
  # 自分以外のログインしているユーザーの場合(ゲストユーザーを除く)
  def signed_in_and_not_guest_or_myself?(user)
    user_signed_in? && user.id != current_user.id && current_user.email != "guest@example.com"
  end

  # 管理者か本人の場合(ゲストユーザーを除く)
  def authorized_user_without_guest?(user)
    current_admin.present? || (current_user.email != "guest@example.com" && user.id == current_user.id)
  end

end

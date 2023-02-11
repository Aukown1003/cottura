module ApplicationHelper
  
  # リンクの作成
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  # 時間の変換
  def jp_time_date(time_date)
    time_date.strftime("%Y年%m月%d日")
  end
  
  # テキストの折返し
  def br_attach(text)
    safe_join(text.split("\n"),tag(:br))
  end
  
  # サインインしているか
  def signed_in?
    admin_signed_in? || user_signed_in?
  end
  
  # ユーザーがゲストユーザーの場合 これもレシピだけかな
  def guest_user?
    current_user.present? && current_user.email == "guest@example.com"
  end
  
  # ユーザーがゲストユーザーまたは他人の場合
  def unauthorized_user?(user)
    user.id != current_user.id || user.email == 'guest@example.com'
  end
  
  # 管理者か本人の場合
  # user_controllerはmodel.idじゃないとだめ
  def authorized_user?(model)
    current_admin.present? || model.id == current_user.id
  end
  
  # 管理者かゲストユーザー以外の本人の場合
  def authorized_user_without_guest?(user)
    current_admin.present? || (current_user.email != "guest@example.com" && user.id == current_user.id)
  end
  
end
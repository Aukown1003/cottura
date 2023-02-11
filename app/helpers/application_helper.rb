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
  
  def jp_time_date(time_date)
    time_date.strftime("%Y年%m月%d日")
  end
  
  def br_attach(text)
    safe_join(text.split("\n"),tag(:br))
  end
end

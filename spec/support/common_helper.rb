module CommonHelpers
  def build_recipe_with_ingredient_and_step(recipe, unit)
    recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
    recipe.recipe_steps.build(attributes_for(:recipe_step))
  end
  
  def save_recipe_with_ingredient_and_step_and_tag(recipe, ingredient_name, unit, step_content, tag_name)
    recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, name: ingredient_name, unit_id: unit.id))
    recipe.recipe_steps.build(attributes_for(:recipe_step, content: step_content))
    recipe.tags.build(name: tag_name)
    recipe.save
  end
  
  def save_recipe_with_ingredient_and_step(recipe, unit)
    recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
    recipe.recipe_steps.build(attributes_for(:recipe_step))
    recipe.save
  end
  
  def expect_redirect_to_with_notice(path, messege)
    expect(response).to redirect_to path
    expect(flash[:notice]).to eq messege
  end
  
  def expect_redirect_to_with_alert(path, messege)
    expect(response).to redirect_to path
    expect(flash[:alert]).to eq messege
  end
  
  def expect_render_to_with_alert(action, messege)
    expect(response).to render_template action
    expect(flash[:alert]).to eq messege
  end
end
module RecipeHelpers
  def save_recipe_with_ingredient_and_step(recipe, unit)
    recipe.recipe_ingredients.build(attributes_for(:recipe_ingredient, unit_id: unit.id))
    recipe.recipe_steps.build(attributes_for(:recipe_step))
    recipe.save
  end
end
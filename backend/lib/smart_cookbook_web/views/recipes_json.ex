defmodule SmartCookbookWeb.RecipesJSON do
  alias SmartCookbook.Recipes.RecipeResponse

  @doc """
  Renders a list of recipes.
  """
  def index(%{recipes: recipes}) do
    %{data: for(recipe <- recipes, do: data(recipe))}
  end

  @doc """
  Renders a single recipe.
  """
  def show(%{recipe: recipe}) do
    %{data: data(recipe)}
  end

  defp data(%RecipeResponse{} = recipe) do
    %{
      name: recipe.name,
      ingredients: recipe.ingredients,
      execution_time: recipe.execution_time,
      calories: recipe.calories,
      instructions: recipe.instructions,
      change_desc: recipe.change_desc,
    }
  end
end

defmodule SmartCookbookWeb.RecipesController do
  use SmartCookbookWeb, :controller

  alias SmartCookbook.Recipes
  alias SmartCookbook.Recipes.RecipeRequest

  action_fallback SmartCookbookWeb.FallbackController

  def generate(conn, request_params) do
    changeset = RecipeRequest.changeset(%RecipeRequest{}, request_params)

    if changeset.valid? do
      recipe_request = Ecto.Changeset.apply_changes(changeset)

      case Recipes.create_recipes(recipe_request) do
        {:ok, recipes} ->
          render(conn, :index, recipes: recipes)
      end
    else
      {:error, :unprocessable_entity, changeset}
    end
  end

  def test_generate(conn, request_params) do
    changeset = RecipeRequest.changeset(%RecipeRequest{}, request_params)

    if changeset.valid? do
      recipe_request = Ecto.Changeset.apply_changes(changeset)

      case Recipes.test_gen_recipes(recipe_request) do
        {:ok, recipes} ->
          render(conn, :index, recipes: recipes)
      end
    else
      {:error, :unprocessable_entity, changeset}
    end
  end
end

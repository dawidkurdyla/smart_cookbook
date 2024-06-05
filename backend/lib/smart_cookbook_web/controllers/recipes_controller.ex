defmodule SmartCookbookWeb.RecipesController do
  use SmartCookbookWeb, :controller

  alias SmartCookbook.Recipes
  alias SmartCookbook.Recipes.RecipeRequest
  alias SmartCookbookWeb.RecipesJSON

  def gen_recipes(conn, request_params) do
    recipe_request = RecipeRequest.changeset(%RecipeRequest{}, request_params)

    if recipe_request.valid? do
      case Recipes.gen_recipes(recipe_request) do
        {:ok, recipes} ->
          json(conn, RecipesJSON.index(%{recipes: recipes}))
        {:error, reason} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: reason})
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: recipe_request.errors})
    end

  end
end

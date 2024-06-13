defmodule SmartCookbookWeb.RecipesController do
  use SmartCookbookWeb, :controller

  alias SmartCookbook.Recipes
  alias SmartCookbook.Recipes.{GenRecipeRequest, UpdateRecipeRequest}

  action_fallback SmartCookbookWeb.FallbackController

  def generate(conn, request_params) do
    changeset = GenRecipeRequest.changeset(%GenRecipeRequest{}, request_params)

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

  def update(conn, request_params) do
    changeset = UpdateRecipeRequest.changeset(%UpdateRecipeRequest{}, request_params)

    if changeset.valid? do
      recipe_request = Ecto.Changeset.apply_changes(changeset)

      case Recipes.update_recipe(recipe_request) do
        {:ok, recipe} ->
          render(conn, :show, recipe: recipe)
      end
    else
      {:error, :unprocessable_entity, changeset}
    end
  end

  def test_generate(conn, request_params) do
    changeset = GenRecipeRequest.changeset(%GenRecipeRequest{}, request_params)

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

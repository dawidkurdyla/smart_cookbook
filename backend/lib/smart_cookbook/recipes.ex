defmodule SmartCookbook.Recipes do
  @moduledoc """
    The Recipies context
  """

  # import AI


  def gen_recipes(_preferences) do
    recipes = [
      %{
        ingredients: ["flour", "sugar", "eggs"],
        execution_time: 45,
        calories: 350,
        instructions: "Mix all ingredients and bake for 30 minutes."
      }
    ]
    {:ok, recipes}
  end

end

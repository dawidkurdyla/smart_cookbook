defmodule SmartCookbook.Recipes.RecipeParser do
  alias SmartCookbook.Recipes.RecipeResponse

  def parse_response({:ok, response}) do
    [name_line | rest] = String.split(response, "\n\n")
    name = String.trim(String.replace(name_line, "Name:", ""))

    ingredients_line = Enum.find(rest, fn section -> String.starts_with?(section, "Ingredients:") end)
    ingredients = parse_ingredients(ingredients_line)

    execution_time_line = Enum.find(rest, fn section -> String.starts_with?(section, "Execution Time:") end)
    execution_time = String.trim(String.replace(execution_time_line, "Execution Time:", ""))

    calories_line = Enum.find(rest, fn section -> String.starts_with?(section, "Calories per portion:") end)
    calories = String.trim(String.replace(calories_line, "Calories per portion:", ""))
               |> String.replace("approximately", "")
               |> String.replace("kcal", "")
               |> String.trim()
               |> String.to_integer()

    instructions_line = Enum.find(rest, fn section -> String.starts_with?(section, "Instructions:") end)
    instructions = parse_instructions(instructions_line)

    recipe = %RecipeResponse{name: name,
    ingredients: ingredients,
    execution_time: execution_time,
    calories: calories,
    instructions: instructions}

    {:ok, [recipe]} #TODO Cover parsing list of recipes
  end

  defp parse_ingredients(ingredients_section) do
    ingredients_section
    |> String.split("\n")
    |> tl()
    |> Enum.map(&String.trim/1)
  end

  defp parse_instructions(instructions_section) do
    instructions_section
    |> String.split("\n")
    |> tl()
    |> Enum.map(&String.trim/1)
  end
end

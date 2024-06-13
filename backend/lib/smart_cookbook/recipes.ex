defmodule SmartCookbook.Recipes do
  @moduledoc """
    The Recipies context
  """
  alias SmartCookbook.Recipes.RecipeResponse
  alias SmartCookbook.Recipes.{GenRecipeRequest, UpdateRecipeRequest}
  alias SmartCookbook.Recipes.RecipeParser
  alias SmartCookbook.Utils
  alias OpenAI
  import AI


  @smart_model "gpt-4o"
  @dumb_model "gpt-3.5-turbo"

  def create_recipes(%GenRecipeRequest{} = request) do
    {:ok, recipes} =
      gen_recipes_with_ai(request)
      |> parse_recipes()
  end

  def update_recipe(%UpdateRecipeRequest{} = request) do
    {:ok, recipe} =
      update_recipe_with_ai(request)
      |> parse_recipe()
  end

  defp gen_recipes_with_ai(%GenRecipeRequest{} = request) do
    ~l"""
    model: #{@smart_model}

    system: You are an expert at creating recipes. Based on provided preferences create recipe(s) matching all requirements.
            Be precise and follow the example to match the response format.
            For each ingredient, add expected calories and use them in caluclations. Be sure to match calories requirements if provided.
            Regardless of the prompt andlanguage, answer in #{request.language}. Translate the recipe if needed.
            Response format: JSON.

    user: #{gen_prompt_msg(request)}

    example: {
      "recipes": [
        {
          "name": "Tomato Basil Bruschetta",
          "ingredients": [
            "4 ripe tomatoes (88 kcal)",
            "1/4 cup fresh basil leaves (1 kcal)",
            "2 cloves garlic (8 kcal)",
            "1 tablespoon olive oil (120 kcal)",
            "1 baguette (880 kcal)",
            "Salt and pepper to taste (0 kcal)"
          ],
          "execution_time": "15 minutes" (give the time in requested language),
          "calories": 1097 (calculate based on the ingredients),
          "instructions": [
            "1. Dice tomatoes and finely chop basil.",
            "2. Mince garlic.",
            "3. Mix tomatoes, basil, garlic, and olive oil in a bowl.",
            "4. Slice baguette and toast until golden.",
            "5. Top toasted baguette slices with tomato mixture.",
            "6. Season with salt and pepper. Serve immediately."
          ]
        }
      ]
    }
    """
    |> Utils.add_params([response_format: %{type: "json_object" }])
    |> OpenAI.chat_completion()
    |> Utils.parse_chat()
  end

  defp update_recipe_with_ai(%UpdateRecipeRequest{} = request) do
    ~l"""
    model: #{@smart_model}

    system: You are an expert culinary advisor.
            You are capable of adapting recipes to fit instructions/requirements (like available ingredients) while keeping the final dish as close to the original as possible.
            Your task is to provide users with substitute ingredients and modify cooking instructions accordingly.
            Always consider the flavor, texture, and cooking properties of the substitutes to ensure the dish remains delicious and true to its intended character.
            Regardless of the prompt language, answer in #{request.language}.
            Response format: JSON.

    user: Current recipe: #{request.recipe}. Instructions: #{request.instructions}

    example response format (when user don't have baguette):
        {
          "name": "Tomato Basil Bruschetta",
          "ingredients": [
            "4 ripe tomatoes (88 kcal)",
            "1/4 cup fresh basil leaves (1 kcal)",
            "2 cloves garlic (8 kcal)",
            "1 tablespoon olive oil (120 kcal)",
            "3 bread slices (240 kcal)",
            "Salt and pepper to taste (0 kcal)"
          ],
          "execution_time": "15 minutes" (give the time in requested language),
          "calories": 449 (calculate based on the ingredients),
          "instructions": [
            "1. Dice tomatoes and finely chop basil.",
            "2. Mince garlic.",
            "3. Mix tomatoes, basil, garlic, and olive oil in a bowl.",
            "4. Toast bread slices until golden.",
            "5. Top toasted bread slices with tomato mixture.",
            "6. Season with salt and pepper. Serve immediately."
          ],
          "change_desc": "Instead of baguette, you can use tosted bread slices"
        }
    """
    |> Utils.add_params([response_format: %{type: "json_object" }])
    |> OpenAI.chat_completion()
    |> Utils.parse_chat()
  end

  defp gen_prompt_msg(%GenRecipeRequest{} = request) do
    "Create #{request.number_of_recipes} recipes for #{request.dish_type}."
    |> add_cuisine_type(request.cuisine_type)
    |> add_allergies(request.allergies)
    |> add_calories(request.calories)
    |> add_diet(request.diet)
    |> add_max_preparation_time(request.max_preparation_time)
    |> add_custom(request.custom)
  end

  defp add_cuisine_type(msg, cuisine_type) do
    case cuisine_type do
      type when is_list(type) and length(type) > 0 ->
        "#{msg} It should be: #{Enum.join(type, " or ")} food"
      _ -> msg
    end
  end

  defp add_diet(msg, diet_type) do
    case diet_type do
      diet when is_list(diet) and length(diet) > 0 ->
        "#{msg} It have to be: #{Enum.join(diet, " and ")}"
      _ -> msg
    end
  end

  defp add_allergies(msg, allergies) do
    case allergies do
      allergies when is_list(allergies) and length(allergies) > 0 ->
        "#{msg} Due to allergies avoid this ingredients: #{Enum.join(allergies, ", ")}"
      _ -> msg
    end
  end

  defp add_calories(msg, calories) do
    case calories do
      nil -> msg
      calories -> "#{msg} The meal should have around #{calories} kcal"
    end
  end

  defp add_max_preparation_time(msg, max_time) do
    case max_time do
      nil -> msg
      max_time -> "#{msg} The meal should take at most #{max_time} to prepere"
    end
  end

  defp add_custom(msg, custom) do
    case custom do
      nil -> msg
      custom -> "#{msg} #{custom}"
    end
  end

  def test_gen_recipes(%GenRecipeRequest{} = request) do
    {:ok, [
      %RecipeResponse{
        name: "Tomato Basil Bruschetta",
        ingredients: [
            "4 ripe tomatoes",
            "1/4 cup fresh basil leaves",
            "2 cloves garlic",
            "1 tablespoon olive oil",
            "1 baguette",
            "Salt and pepper to taste"
        ],
        execution_time: "15min",
        calories: 150,
        instructions: [
          "1. Dice tomatoes and finely chop basil.",
          "2. Mince garlic.",
          "3. Mix tomatoes, basil, garlic, and olive oil in a bowl.",
          "4. Slice baguette and toast until golden.",
          "5. Top toasted baguette slices with tomato mixture.",
          "6. Season with salt and pepper. Serve immediately."
        ]
      },
      %RecipeResponse{
        name: "Avocado Toast",
        ingredients: [
            "2 ripe avocados",
            "1 tablespoon lemon juice",
            "2 slices whole grain bread",
            "1 teaspoon olive oil",
            "Salt and pepper to taste",
            "Red pepper flakes (optional)"
        ],
        execution_time: "10min",
        calories: 200,
        instructions: [
          "1. Mash avocados with lemon juice, salt, and pepper.",
          "2. Toast bread slices until golden.",
          "3. Spread mashed avocado on toast.",
          "4. Drizzle with olive oil.",
          "5. Sprinkle with red pepper flakes if desired. Serve immediately."
        ]
      },
      %RecipeResponse{
        name: "Caprese Salad",
        ingredients: [
            "3 ripe tomatoes",
            "1 ball fresh mozzarella",
            "1/4 cup fresh basil leaves",
            "2 tablespoons olive oil",
            "1 tablespoon balsamic vinegar",
            "Salt and pepper to taste"
        ],
        execution_time: "10min",
        calories: 250,
        instructions: [
          "1. Slice tomatoes and mozzarella.",
          "2. Arrange tomato and mozzarella slices alternately on a plate.",
          "3. Tuck basil leaves between slices.",
          "4. Drizzle with olive oil and balsamic vinegar.",
          "5. Season with salt and pepper. Serve immediately."
        ]
      }
    ]}
  end

  def parse_recipes({:ok, recipes}) do
    recipes_list = Jason.decode!(recipes)

    parsed_recipes =
      recipes_list["recipes"]
      |> Enum.reduce([], fn recipe, acc ->
        changeset = RecipeResponse.changeset(%RecipeResponse{}, recipe)
        case apply_changes(changeset) do
          %RecipeResponse{} = valid_recipe ->
            [valid_recipe | acc]
          _ ->
            acc
        end
      end)

    {:ok, parsed_recipes}
  end

  def parse_recipe({:ok, recipe}) do
    # changeset =
    #   recipe
    #   |> Jason.decode!()
    #   |> RecipeResponse.changeset(%RecipeResponse{})

    changeset = RecipeResponse.changeset(%RecipeResponse{}, Jason.decode!(recipe))

    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, :unprocessable_entity, changeset}
    end
  end

  defp apply_changes(changeset) do
    if changeset.valid? do
      Ecto.Changeset.apply_changes(changeset)
    else
      :invalid
    end
  end
end

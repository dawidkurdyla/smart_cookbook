defmodule SmartCookbook.Recipes do
  alias SmartCookbook.Recipes.RecipeResponse
  alias SmartCookbook.Recipes.RecipeRequest
  alias SmartCookbook.Recipes.RecipeParser
  alias SmartCookbook.OpenAIClient
  @moduledoc """
    The Recipies context
  """
  alias OpenAI
  import AI


  # @model "gpt-4"
  @model "bartowski/Starling-LM-7B-beta-GGUF"

  def gen_recipes(%RecipeRequest{} = request) do
    # config = Application.get_env(:openai, OpenAI)
    # IO.inspect("CONFIG OPENAI")
    # IO.inspect(config)

    # api_key = Application.get_env(:openai, OpenAI)[:api_key]
    # base_url = Application.get_env(:openai, OpenAI)[:base_url]

    # headers = [
    #   {"Authorization", "Bearer #{api_key}"}
    # ]

    # IO.inspect(base_url, label: "Base URL")
    # IO.inspect(headers, label: "Headers")

    # OpenAI.chat_completion(
    #   %{
    #     model: "bartowski/Starling-LM-7B-beta-GGUF",
    #     messages: [%{role: "user", content: "Say HI!", stream: false}]
    #   },
    #   headers: headers,
    #   base_url: base_url
    # )
    # OpenAIClient.generate_prompt("HI")
    # |> IO.inspect()

    # ~l"""
    #   model: #{@model}
    #   system: You are an expert at creating recipes. Based on provided preferences create recipe(s) matching all requirements. Be precise and follow the example to match the response format.
    #   user: #{gen_prompt_msg(request)}

    #   Example
    #     name:"Tomato Basil Bruschetta",
    #     ingredients:[
    #       "4 ripe tomatoes",
    #       "1/4 cup fresh basil leaves",
    #       "2 cloves garlic",
    #       "1 tablespoon olive oil",
    #       "1 baguette",
    #       "Salt and pepper to taste"
    #     ],
    #     execution_time:15,
    #     calories:150,
    #     instructions:[
    #       "1. Dice tomatoes and finely chop basil.",
    #       "2. Mince garlic." ,
    #       "3. Mix tomatoes, basil, garlic, and olive oil in a bowl.",
    #       "4. Slice baguette and toast until golden.",
    #       "5. Top toasted baguette slices with tomato mixture.",
    #       "6. Season with salt and pepper. Serve immediately."
    #     ]
    # """
    recipe = %{
      system: "You are an expert at creating recipes. Based on provided preferences create recipe(s) matching all requirements. Be precise and follow the example to match the response format.",
      user: """
        #{gen_prompt_msg(request)}

        Example
          name:"Tomato Basil Bruschetta",
          ingredients:[
            "4 ripe tomatoes",
            "1/4 cup fresh basil leaves",
            "2 cloves garlic",
            "1 tablespoon olive oil",
            "1 baguette",
            "Salt and pepper to taste"
          ],
          execution_time:15,
          calories:150,
          instructions:[
            "1. Dice tomatoes and finely chop basil.",
            "2. Mince garlic." ,
            "3. Mix tomatoes, basil, garlic, and olive oil in a bowl.",
            "4. Slice baguette and toast until golden.",
            "5. Top toasted baguette slices with tomato mixture.",
            "6. Season with salt and pepper. Serve immediately."
          ]

          Answer in JSON format, do not add any additional information or text. Just the JSON with recipe.
      """
    }
    |> OpenAIClient.generate_prompt()
    |> IO.inspect()
    |> RecipeParser.parse_response()
    # |> OpenAI.chat_completion()
    # # |> AI.chat()
    # |> IO.inspect()


    {:ok, recipe}
  end

  defp gen_prompt_msg(%RecipeRequest{} = request) do
    "Create #{request.number_of_recipes} recipes for #{request.dish_type}."
    |> add_cuisine_type(request.cuisine_type)
    |> add_allergies(request.allergies)
    |> add_calories(request.calories)
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
      calories -> "#{msg} The meal should have around #{calories} kcal per portion"
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


  def test_gen_recipes(%RecipeRequest{} = request) do
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
end

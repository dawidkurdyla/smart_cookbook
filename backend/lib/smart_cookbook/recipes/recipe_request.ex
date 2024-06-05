defmodule SmartCookbook.Recipes.RecipeRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @dish_types ~w(Breakfast Lunch Dinner Snack)a

  embedded_schema do
    field :cuisine_type, {:array, :string}
    field :dish_type, Ecto.Enum, values: @dish_types
    field :allergies, {:array, :string}
    field :number_of_recipes, :integer
    field :calories, :integer
    field :max_preparation_time, :integer
    field :custom, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:cuisine_type, :dish_type, :allergies, :number_of_recipes, :calories, :max_preparation_time, :custom])
    |> validate_inclusion(:dish_type, @dish_types)
  end
end

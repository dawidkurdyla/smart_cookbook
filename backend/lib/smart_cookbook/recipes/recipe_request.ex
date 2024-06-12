defmodule SmartCookbook.Recipes.RecipeRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @dish_types [:breakfast, :lunch, :snack]
  embedded_schema do
    field :dish_type, Ecto.Enum, values: @dish_types
    field :cuisine_type, {:array, :string}, default: []
    field :diet, {:array, :string}, default: []
    field :calories, :integer
    field :max_preparation_time, :string
    field :allergies, {:array, :string}, default: []
    field :number_of_recipes, :integer, default: 3
    field :custom, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:cuisine_type, :dish_type, :diet, :allergies, :number_of_recipes, :calories, :max_preparation_time, :custom])
    |> validate_inclusion(:dish_type, @dish_types)
  end
end

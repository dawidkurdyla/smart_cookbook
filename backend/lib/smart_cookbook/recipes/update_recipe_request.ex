defmodule SmartCookbook.Recipes.UpdateRecipeRequest do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :recipe, :string
    field :instructions, :string
    field :language, :string, default: "english"
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:recipe, :instructions, :language])
    |> validate_required(:recipe, :instructions)
  end
end

defmodule SmartCookbookWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("error.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end

  def render("error.json", %{reason: reason}) do
    %{errors: %{detail: reason}}
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      case opts do
        [type: {:parameterized, Ecto.Enum, _} = enum_type, validation: :cast] ->
          "#{msg} (expected one of: #{Enum.join(enum_values(enum_type), ", ")})"

        _ ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
      end
    end)
  end

  defp enum_values({:parameterized, Ecto.Enum, %{on_cast: on_cast}}) do
    Map.keys(on_cast)
  end

end

defmodule SmartCookbook.Utils do
  def parse_chat({:ok, %{choices: [%{"message" => %{"content" => content}} | _]}}) do
    {:ok, content}
  end

  def parse_chat(%{"error" => %{"message" => message}}) do
    {:error, message}
  end

  def parse_chat(_), do: {:error, "Unexpected format"}
end

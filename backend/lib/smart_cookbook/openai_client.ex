defmodule SmartCookbook.OpenAIClient do
  @moduledoc """
  A client for interacting with the OpenAI API.
  """

  @api_url "http://localhost:2137/v1/chat/completions"
  @api_key "lm-studio"
  @timeout 60_000        # 60 seconds timeout for connection establishment
  @recv_timeout 60_000   # 60 seconds timeout for receiving the response

  def generate_prompt(%{system: sys_content, user: user_content}) do
    body = %{
        "model" =>"bartowski/Starling-LM-7B-beta-GGUF",
        "messages" => [
          %{ role: "system", content: sys_content},
          %{ role: "user", content: user_content}
        ],
        # "max_tokens" => 150,
        # "temperature" => 0.7,
        # "stream" => false,
      }
    |> Jason.encode!()
    # body = prompt
    IO.inspect(body)

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{@api_key}"}
    ]
    options = [
      timeout: @timeout,
      recv_timeout: @recv_timeout
    ]

    case HTTPoison.post(@api_url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> parse_chat()

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Failed with status code: #{status_code}, body: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end

defp parse_chat(%{"choices" => [%{"message" => %{"content" => content}} | _]}),
  do: {:ok, content}

defp parse_chat(%{"error" => %{"message" => message}}), do: {:error, message}
defp parse_chat(_), do: {:error, "Unexpected response format"}
end

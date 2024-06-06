defmodule SmartCookbookWeb.FallbackController do
  use SmartCookbookWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(SmartCookbookWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unprocessable_entity, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(SmartCookbookWeb.ErrorJSON)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:bad_request)
    |> put_view(SmartCookbookWeb.ErrorJSON)
    |> render("error.json", reason: reason)
  end
end

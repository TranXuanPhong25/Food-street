defmodule FoodStreetWeb.Admin.SettingsController do
  @moduledoc "Admin cấu hình Panchat token của riêng mình (mỗi admin một token)."
  use FoodStreetWeb, :controller

  alias FoodStreet.Settings
  alias FoodStreet.Guardian

  action_fallback FoodStreetWeb.FallbackController

  # Trạng thái Panchat token của chính admin đang đăng nhập.
  # KHÔNG trả full token, chỉ trả preview 4 ký tự cuối.
  def show(conn, _params) do
    admin = Guardian.Plug.current_resource(conn)
    json(conn, %{data: panchat_status(admin.id)})
  end

  def update(conn, params) do
    admin = Guardian.Plug.current_resource(conn)
    token = params["panchat_token"] || params["token"] || ""

    if String.trim(token) == "" do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "empty_token", message: "Token không được để trống."})
    else
      with {:ok, _} <- Settings.put_panchat_token(admin.id, String.trim(token)) do
        json(conn, %{data: panchat_status(admin.id)})
      end
    end
  end

  defp panchat_status(user_id) do
    token = Settings.panchat_token(user_id)

    %{
      panchat_configured: Settings.panchat_configured?(user_id),
      panchat_token_preview: mask(token)
    }
  end

  defp mask(nil), do: ""
  defp mask(""), do: ""

  defp mask(token) when is_binary(token) do
    last4 = token |> String.slice(-4, 4)
    "••••" <> (last4 || "")
  end
end

defmodule FoodStreetWeb.Admin.FundController do
  use FoodStreetWeb, :controller

  alias FoodStreet.Fund
  alias FoodStreet.Accounts
  alias FoodStreet.Guardian

  action_fallback FoodStreetWeb.FallbackController

  def index(conn, _params) do
    data = Enum.map(Fund.list_transactions(), &shape/1)
    json(conn, %{data: data})
  end

  # Gắn kèm tên người dùng + người thực hiện vào giao dịch để admin xem.
  defp shape(tx) do
    tx
    |> Map.take([
      :id,
      :user_id,
      :amount,
      :type,
      :description,
      :balance_after,
      :order_id,
      :created_by_id,
      :inserted_at
    ])
    |> Map.put(:user, user_map(tx.user))
    |> Map.put(:created_by, user_map(tx.created_by))
  end

  defp user_map(%{id: id, name: name}), do: %{id: id, name: name}
  defp user_map(_), do: nil

  def deposit(conn, %{"user_id" => user_id, "amount" => amount} = params) do
    admin = Guardian.Plug.current_resource(conn)

    case Accounts.get_user(user_id) do
      nil ->
        {:error, :not_found}

      user ->
        with {:ok, result} <- Fund.deposit(user, amount, admin, params["description"]) do
          conn |> put_status(:created) |> json(%{data: result})
        end
    end
  end

  def deposit(_conn, _params), do: {:error, :missing_params}

  def adjust(conn, %{"user_id" => user_id, "amount" => amount} = params) do
    admin = Guardian.Plug.current_resource(conn)

    case Accounts.get_user(user_id) do
      nil ->
        {:error, :not_found}

      user ->
        with {:ok, result} <- Fund.adjust(user, amount, admin, params["description"]) do
          conn |> put_status(:created) |> json(%{data: result})
        end
    end
  end

  def adjust(_conn, _params), do: {:error, :missing_params}
end

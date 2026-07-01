defmodule FoodStreet.Settings.Setting do
  @moduledoc "Một cặp key-value cấu hình, gắn theo từng user (mỗi admin một token riêng)."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: [:id, :user_id, :key, :value, :inserted_at, :updated_at]}

  schema "settings" do
    field :user_id, :binary_id
    field :key, :string
    field :value, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:user_id, :key, :value])
    |> validate_required([:user_id, :key])
    |> unique_constraint([:user_id, :key], name: :settings_user_id_key_index)
  end
end

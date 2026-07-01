defmodule FoodStreet.Repo.Migrations.ScopeSettingsToUser do
  @moduledoc """
  Tách `settings` theo từng user: mỗi admin có token Panchat riêng.

  Trước đây `settings` là key-value toàn cục (unique theo `key`), nên admin nào
  lưu token sau cùng sẽ ghi đè cho cả hệ thống → admin A tạo đợt lại gửi tin bằng
  token của admin B. Sau migration, mỗi (user_id, key) là 1 dòng riêng.

  Dòng global cũ (không có user_id) bị xoá — mỗi admin phải nhập lại token của mình.
  """
  use Ecto.Migration

  def up do
    # Cột user_id sẽ NOT NULL nên phải bỏ các dòng global cũ (không gắn user) trước.
    execute("DELETE FROM settings")

    alter table(:settings) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
    end

    drop unique_index(:settings, [:key])
    create unique_index(:settings, [:user_id, :key])
  end

  def down do
    drop unique_index(:settings, [:user_id, :key])

    alter table(:settings) do
      remove :user_id
    end

    create unique_index(:settings, [:key])
  end
end

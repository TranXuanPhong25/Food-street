defmodule FoodStreet.Repo.Migrations.AddPanchatUserIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # UUID user Panchat (workcake) — dùng để mention thật (@Tên) khi báo số dư.
      add :panchat_user_id, :string
    end
  end
end

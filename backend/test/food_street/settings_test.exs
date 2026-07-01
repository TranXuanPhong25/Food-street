defmodule FoodStreet.SettingsTest do
  use FoodStreet.DataCase, async: true

  alias FoodStreet.Settings
  alias FoodStreet.Accounts

  defp admin!(username) do
    {:ok, user} =
      Accounts.create_user(%{
        name: "Admin #{username}",
        username: username,
        email: "#{username}@example.com",
        password: "password123",
        role: "admin"
      })

    user
  end

  describe "key-value settings (scoped per user)" do
    test "get_value returns default when missing" do
      u = admin!("u_missing")
      assert Settings.get_value(u.id, "nope") == nil
      assert Settings.get_value(u.id, "nope", "fallback") == "fallback"
    end

    test "put_value inserts then updates (upsert by user+key)" do
      u = admin!("u_upsert")
      assert {:ok, _} = Settings.put_value(u.id, "k", "v1")
      assert Settings.get_value(u.id, "k") == "v1"

      assert {:ok, _} = Settings.put_value(u.id, "k", "v2")
      assert Settings.get_value(u.id, "k") == "v2"
    end
  end

  describe "panchat token (per user)" do
    test "not configured by default" do
      u = admin!("u_default")
      refute Settings.panchat_configured?(u.id)
      assert Settings.panchat_token(u.id) == nil
    end

    test "configured after saving a non-blank token" do
      u = admin!("u_saved")
      assert {:ok, _} = Settings.put_panchat_token(u.id, "abc123")
      assert Settings.panchat_configured?(u.id)
      assert Settings.panchat_token(u.id) == "abc123"
    end

    test "blank token counts as not configured" do
      u = admin!("u_blank")
      assert {:ok, _} = Settings.put_panchat_token(u.id, "   ")
      refute Settings.panchat_configured?(u.id)
    end

    test "one admin's token does not leak to another" do
      a = admin!("admin_a")
      b = admin!("admin_b")

      assert {:ok, _} = Settings.put_panchat_token(a.id, "token-A")

      assert Settings.panchat_token(a.id) == "token-A"
      assert Settings.panchat_configured?(a.id)

      # B chưa nhập token → không thấy token của A
      assert Settings.panchat_token(b.id) == nil
      refute Settings.panchat_configured?(b.id)
    end
  end
end

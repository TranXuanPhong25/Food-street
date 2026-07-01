defmodule FoodStreet.PanchatTest do
  use ExUnit.Case, async: true

  alias FoodStreet.Panchat
  alias FoodStreet.Ordering.GroupOrder

  describe "invite_text/1" do
    test "contains title, date and app link (@all is sent via mention attachment, not text)" do
      go = %GroupOrder{title: "Ăn sáng thứ 2", order_date: ~D[2026-07-01], note: nil}
      text = Panchat.invite_text(go)

      assert text =~ "Ăn sáng thứ 2"
      assert text =~ "2026-07-01"
      assert text =~ "/app"
    end

    test "includes note when present, omits when blank" do
      with_note =
        Panchat.invite_text(%GroupOrder{title: "X", order_date: ~D[2026-07-01], note: "Chốt 8h"})

      assert with_note =~ "Chốt 8h"

      without_note =
        Panchat.invite_text(%GroupOrder{title: "X", order_date: ~D[2026-07-01], note: nil})

      refute without_note =~ "📝"
    end
  end

  describe "send_breakfast_invite/2" do
    test "returns error when token is missing (nil or blank) without calling network" do
      go = %GroupOrder{title: "X", order_date: ~D[2026-07-01], note: nil}

      assert Panchat.send_breakfast_invite(go, nil) == {:error, :panchat_token_missing}
      assert Panchat.send_breakfast_invite(go, "   ") == {:error, :panchat_token_missing}
    end
  end

  describe "build_body/1" do
    test "builds the Panchat payload (uuid key, @all via mention attachment)" do
      body = Panchat.build_body("hello")

      assert body.workspace_id == 4
      assert body.channel_id == 11_813
      assert body.channel_thread_id == nil
      assert body.message == "hello"
      assert is_integer(body.current_time)
      assert {:ok, _} = Ecto.UUID.cast(body.key)

      # @all được gửi qua mention attachment (không nhét vào text).
      assert [mention] = body.attachments
      assert mention["type"] == "mention"

      assert [%{"type" => "all", "trigger" => "@", "name" => "all", "value" => 11_813}] =
               mention["data"]
    end
  end
end

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

  describe "close_text/3 và send_group_closed_summary/4" do
    test "close_text chứa tiêu đề, ngày, số đơn và tổng tiền định dạng VN" do
      go = %GroupOrder{id: "abc", title: "Sáng T2", order_date: ~D[2026-07-02]}
      text = Panchat.close_text(go, 3, Decimal.new("90000"))

      assert text =~ "Sáng T2"
      assert text =~ "2026-07-02"
      assert text =~ "3 đơn"
      assert text =~ "90.000đ"
    end

    test "send_group_closed_summary lỗi khi thiếu token, không gọi mạng" do
      go = %GroupOrder{id: "abc", title: "X", order_date: ~D[2026-07-02]}

      assert Panchat.send_group_closed_summary(go, 1, Decimal.new("1000"), nil) ==
               {:error, :panchat_token_missing}

      assert Panchat.send_group_closed_summary(go, 1, Decimal.new("1000"), "  ") ==
               {:error, :panchat_token_missing}
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

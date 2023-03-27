defmodule ScoreboardWeb.ScoreboardControllerTest do
  use ScoreboardWeb.ConnCase

  alias Scoreboard.User

  describe "home" do
    test "returns users and timestamp", %{conn: conn} do
      {:ok, _user1} = User.create(%{points: 200})
      {:ok, _user2} = User.create(%{points: 300})

      conn = get(conn, ~p"/")

      assert %{"timestamp" => _timestamp, "users" => users} = json_response(conn, 200)
      assert length(users) == 2
    end
  end
end

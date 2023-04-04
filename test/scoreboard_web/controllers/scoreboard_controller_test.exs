defmodule ScoreboardWeb.ScoreboardControllerTest do
  use ScoreboardWeb.ConnCase

  alias Scoreboard
  alias Scoreboard.Users

  setup do
    {:ok, _pid} = Scoreboard.Server.start_link()

    :ok
  end

  describe "home" do
    test "returns users and timestamp", %{conn: conn} do
      :ok = Scoreboard.Server.set_min_number(Users.min_points_value())
      {:ok, _user1} = Users.create(%{points: Users.max_points_value()})
      {:ok, _user2} = Users.create(%{points: Users.max_points_value()})
      Scoreboard.Server.set_min_number(Users.min_points_value())

      conn = get(conn, ~p"/")

      assert %{"timestamp" => _timestamp, "users" => users} = json_response(conn, 200)
      assert length(users) == 2
    end
  end
end

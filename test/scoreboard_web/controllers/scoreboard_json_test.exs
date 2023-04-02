defmodule ScoreboardWeb.ScoreboardJsonTest do
  use ScoreboardWeb.ConnCase, async: true

  alias Scoreboard.Users
  alias ScoreboardWeb.ScoreboardJSON, as: Subject

  test "renders home" do
    {:ok, user1} = Users.create(%{points: Users.max_points_value()})
    {:ok, user2} = Users.create(%{points: Users.min_points_value()})

    now = DateTime.utc_now()

    assert %{timestamp: nil, users: users} =
             Subject.home(%{users: [user1, user2], timestamp: nil})

    assert %{id: user1.id, points: user1.points} in users
    assert %{id: user2.id, points: user2.points} in users

    assert %{timestamp: timestamp, users: []} =
             Subject.home(%{
               users: [],
               timestamp: now
             })

    assert timestamp == now
  end
end

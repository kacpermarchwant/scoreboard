defmodule ScoreboardWeb.ScoreboardJsonTest do
  use ScoreboardWeb.ConnCase, async: true

  alias Scoreboard.User
  alias ScoreboardWeb.ScoreboardJSON, as: Subject

  test "renders home" do
    {:ok, user1} = User.create(%{points: 200})
    {:ok, user2} = User.create(%{points: 300})
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

defmodule Scoreboard.PointsUpdaterTest do
  use Scoreboard.DataCase

  alias Scoreboard.User
  alias Scoreboard.Repo
  alias Scoreboard.PointsUpdate
  alias Scoreboard.PointsUpdater, as: Subject

  describe "init/1" do
    test "if any points_update has :next_update_date that is in the past, the function deletes it and randomizes points" do
      yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)
      PointsUpdate.schedule(yesterday)
      {:ok, user1} = User.create(%{points: 200})
      {:ok, user2} = User.create(%{points: 200})

      Subject.init(%{})

      user1 = Repo.get!(User, user1.id)
      user2 = Repo.get!(User, user2.id)

      assert user1.points >= 1 and user1.points <= 100
      assert user2.points >= 1 and user2.points <= 100
      assert 0 == Repo.aggregate(PointsUpdate, :count)
    end
  end
end

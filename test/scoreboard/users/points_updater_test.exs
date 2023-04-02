defmodule Scoreboard.Users.PointsUpdaterTest do
  use Scoreboard.DataCase

  alias Scoreboard.Repo
  alias Scoreboard.Users.User
  alias Scoreboard.Users.PointsUpdate
  alias Scoreboard.Users.PointsUpdater, as: Subject

  describe "init/1" do
    setup do
      {:ok, user1} = User.create(%{points: User.max_points_value()})
      {:ok, user2} = User.create(%{points: User.max_points_value()})

      {:ok, user1: user1, user2: user2}
    end

    test "if any points_update has :next_update_date that is in the past, the function deletes it and randomizes users points",
         %{user1: user1, user2: user2} do
      yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)
      PointsUpdate.schedule(yesterday, User.min_points_value(), User.min_points_value())

      Subject.init([])

      user1 = Repo.get!(User, user1.id)
      user2 = Repo.get!(User, user2.id)

      assert user1.points == User.min_points_value()
      assert user2.points == User.min_points_value()
      assert 0 == Repo.aggregate(PointsUpdate, :count)
    end

    test "if no points_update has :next_update_date that is in the past, the function doesn't do anything",
         %{user1: user1, user2: user2} do
      tommorow = DateTime.utc_now() |> DateTime.add(1, :day)
      PointsUpdate.schedule(tommorow)

      Subject.init([])

      user1_after_init = Repo.get!(User, user1.id)
      user2_after_init = Repo.get!(User, user2.id)

      assert user1.points == user1_after_init.points
      assert user2.points == user2_after_init.points
      assert 1 == Repo.aggregate(PointsUpdate, :count)
    end
  end

  describe "handle_cast/3 {:update_points, update_function}" do
    test "calls update_function" do
      update_function = fn -> send(self(), :update_function_called) end

      Subject.handle_cast({:update_points, update_function}, %{})

      assert_receive :update_function_called
    end
  end
end

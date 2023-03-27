defmodule Scoreboard.UserTest do
  use Scoreboard.DataCase, async: true

  alias Scoreboard.Repo
  alias Scoreboard.PointsUpdate
  alias Scoreboard.User, as: Subject

  describe "create/1" do
    test "given valid params, returns {:ok, struct}" do
      assert {:ok, %Subject{}} = Subject.create(%{points: 70})
    end

    test "requires points" do
      assert {:error, _changest} = Subject.create(%{})
    end
  end

  describe "get_users_with_more_points_than/1" do
    setup do
      {:ok, user_50} = Subject.create(%{points: 50})
      {:ok, user_60} = Subject.create(%{points: 60})
      {:ok, user_70} = Subject.create(%{points: 70})

      {:ok, user_50: user_50, user_60: user_60, user_70: user_70}
    end

    test "only returns users with points bigger than given argument", %{user_70: user_70} do
      assert [user_70] == Subject.get_users_with_more_points_than(60)
    end

    test "given 3 matching results, returns only 2 of them", %{user_60: user_60, user_70: user_70} do
      result = Subject.get_users_with_more_points_than(57)

      assert user_60 in result
      assert user_70 in result
      assert length(result) == 2
    end

    test "given 1 matching result, return it", %{user_70: user_70} do
      assert [user_70] == Subject.get_users_with_more_points_than(65)
    end

    test "given 0 matching results, returns an empty list" do
      assert [] == Subject.get_users_with_more_points_than(999)
    end
  end

  describe "randomize_points" do
    test "updates points of all users to an integer between 1 and 100" do
      {:ok, user1} = Subject.create(%{points: 200})
      {:ok, user2} = Subject.create(%{points: 200})

      :ok = Subject.randomize_points()

      user1 = Repo.get!(Subject, user1.id)
      user2 = Repo.get!(Subject, user2.id)

      assert user1.points >= 1 and user1.points <= 100
      assert user2.points >= 1 and user2.points <= 100
    end

    test "deletes all point_updates with :next_update_date in the past" do
      yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)

      PointsUpdate.schedule(yesterday)

      :ok = Subject.randomize_points()

      assert 0 == Repo.aggregate(PointsUpdate, :count)
    end
  end
end

defmodule Scoreboard.Users.UserTest do
  use Scoreboard.DataCase, async: true

  alias Scoreboard.Repo
  alias Scoreboard.Users.PointsUpdate
  alias Scoreboard.Users.User, as: Subject

  describe "create/1" do
    test "given valid params, returns {:ok, %Subject{}} and creates an instance of the Subject with given amount of points" do
      points = Subject.max_points_value()

      assert {:ok, %Subject{id: id}} = Subject.create(%{points: points})
      assert %Subject{points: ^points} = Repo.get!(Subject, id)
    end

    test "requires points field" do
      assert {:error, _changest} = Subject.create(%{})
    end

    test "thorws an error if given point value is not valid" do
      assert {:error, _changeset} = Subject.create(%{points: Subject.max_points_value() + 1})
      assert {:error, _changeset} = Subject.create(%{points: Subject.min_points_value() - 1})
    end
  end

  describe "users_with_more_points_than/1" do
    setup do
      {:ok, user_50} = Subject.create(%{points: 50})
      {:ok, user_60} = Subject.create(%{points: 60})
      {:ok, user_70} = Subject.create(%{points: 70})

      {:ok, user_50: user_50, user_60: user_60, user_70: user_70}
    end

    test "only returns users with points bigger than given argument", %{user_70: user_70} do
      assert [user_70] == Subject.users_with_more_points_than(60)
    end

    test "given 3 matching results, returns only 2 of them", %{user_60: user_60, user_70: user_70} do
      result = Subject.users_with_more_points_than(57)

      assert user_60 in result
      assert user_70 in result
      assert length(result) == 2
    end

    test "given 1 matching result, return it", %{user_70: user_70} do
      assert [user_70] == Subject.users_with_more_points_than(65)
    end

    test "given 0 matching results, returns an empty list" do
      assert [] == Subject.users_with_more_points_than(999)
    end
  end

  describe "randomize_points/2" do
    test "returns :error if min_value is too low" do
      assert {:error, :min_value_is_too_low} ==
               Subject.randomize_points(
                 Subject.min_points_value() - 1,
                 Subject.max_points_value()
               )
    end

    test "returns :error if max_value is too high" do
      assert {:error, :max_value_is_too_high} ==
               Subject.randomize_points(
                 Subject.min_points_value(),
                 Subject.max_points_value() + 1
               )
    end

    test "returns :errro if min_value is bigger than max_value" do
      assert {:error, :invalid_values} ==
               Subject.randomize_points(Subject.max_points_value(), Subject.min_points_value())
    end

    test "updates points of all users to an integer between min_value and max_value" do
      {:ok, user1} = Subject.create(%{points: Subject.max_points_value()})
      {:ok, user2} = Subject.create(%{points: Subject.min_points_value()})
      min_value = Subject.min_points_value() + 1
      max_value = Subject.max_points_value() - 1

      :ok = Subject.randomize_points(min_value, max_value)

      user1 = Repo.get!(Subject, user1.id)
      user2 = Repo.get!(Subject, user2.id)

      assert user1.points >= min_value and user1.points <= max_value
      assert user2.points >= min_value and user2.points <= max_value
    end

    test "deletes all point_updates with :next_update_date in the past" do
      yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)

      PointsUpdate.schedule(yesterday)

      :ok = Subject.randomize_points()

      assert 0 == Repo.aggregate(PointsUpdate, :count)
    end
  end
end

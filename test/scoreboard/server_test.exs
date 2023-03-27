defmodule Scoreboard.ServerTest do
  use Scoreboard.DataCase

  alias Scoreboard.User
  alias Scoreboard.Server, as: Subject

  describe "get_users_and_timestamp/0" do
    setup do
      {:ok, user1} = User.create(%{points: 200})
      {:ok, user2} = User.create(%{points: 200})

      {:ok, user1: user1, user2: user2}
    end

    test "returns users with more points than min_number and timestamp that updates after each call to the current timestamp",
         %{
           user1: user1,
           user2: user2
         } do
      now = DateTime.utc_now()

      assert %{users: users} = Subject.get_users_and_timestamp()

      assert user1 in users
      assert user2 in users

      assert %{timestamp: timestamp} = Subject.get_users_and_timestamp()
      assert timestamp != nil
      assert DateTime.compare(timestamp, now) != :lt
    end
  end

  describe "init/1" do
    test "initial :min_number is a number between 1 and 100" do
      assert {:ok, %{min_number: min_number}} = Subject.init(%{})
      assert min_number >= 1 and min_number <= 100
    end

    test "initial :timestamp equals to nil" do
      assert {:ok, %{timestamp: nil}} = Subject.init(%{})
    end
  end
end

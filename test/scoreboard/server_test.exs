defmodule Scoreboard.ServerTest do
  use Scoreboard.DataCase

  alias Scoreboard.Users
  alias Scoreboard.Server, as: Subject

  describe "get_users_and_timestamp/0" do
    setup do
      {:ok, _pid} = Scoreboard.Server.start_link()
      {:ok, user1} = Users.create(%{points: Users.max_points_value()})
      {:ok, user2} = Users.create(%{points: Users.max_points_value()})
      :ok = Subject.set_min_number(Users.min_points_value())

      {:ok, user1: user1, user2: user2}
    end

    test "returns users with more points than min_number and timestamp that updates after each call to the current timestamp",
         %{
           user1: user1,
           user2: user2
         } do
      now = DateTime.utc_now()

      assert %{users: users, timestamp: nil} = Subject.users_and_timestamp()
      assert user1 in users
      assert user2 in users
      assert %{timestamp: timestamp} = Subject.users_and_timestamp()
      assert timestamp != nil
      assert DateTime.compare(timestamp, now) != :lt
    end
  end

  describe "init/1" do
    test "initial :min_number is a number between min_points_value and max_points_value" do
      assert {:ok, %{min_number: min_number}} = Subject.init([])
      assert min_number >= Users.min_points_value() and min_number <= Users.max_points_value()
    end

    test "initial :timestamp equals to nil" do
      assert {:ok, %{timestamp: nil}} = Subject.init([])
    end

    test "schedules update after given interval" do
      update_interval = 1

      Subject.init(update_interval: update_interval)

      assert_receive {:update, ^update_interval, _}
    end
  end

  describe "handle_info/3 {:update, update_interval, update_function}" do
    test "calls update_function" do
      update_function = fn -> send(self(), :update_function_called) end

      Subject.handle_info(
        {:update, 1000, update_function},
        %{min_number: Users.max_points_value()}
      )

      assert_receive :update_function_called
    end

    test "schedules another update after given interval" do
      update_interval = 1

      Subject.handle_info(
        {:update, update_interval, fn -> :ok end},
        %{min_number: Users.max_points_value()}
      )

      assert_receive {:update, ^update_interval, _}
    end
  end
end

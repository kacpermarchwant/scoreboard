defmodule Scoreboard.Users.PointsUpdaterTest do
  use Scoreboard.DataCase

  alias Scoreboard.Users.PointsUpdate
  alias Scoreboard.Users.PointsUpdater, as: Subject

  describe "init/1" do
    test "if any points_update has :next_update_date that is in the past, the function deletes it and calls update function" do
      yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)
      PointsUpdate.schedule(yesterday)

      Subject.init(update_function: fn _, _ -> send(self(), :update_function_called) end)

      assert_receive :update_function_called
    end

    test "if no points_update has :next_update_date that is in the past, the function doesn't do anything" do
      tommorow = DateTime.utc_now() |> DateTime.add(1, :day)
      PointsUpdate.schedule(tommorow)

      Subject.init(update_function: fn _, _ -> send(self(), :update_function_called) end)

      refute_receive :update_function_called
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

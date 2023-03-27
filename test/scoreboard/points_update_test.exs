defmodule Scoreboard.PointsUpdateTest do
  use Scoreboard.DataCase, async: true

  alias Scoreboard.Repo
  alias Scoreboard.PointsUpdate, as: Subject

  describe "schedule/1" do
    test "creates a points_update" do
      assert :ok = Subject.schedule(DateTime.utc_now())
      assert 1 == Repo.aggregate(Subject, :count)
    end
  end

  describe "update_done/1" do
    test "deletes all points_updates with :next_update_date before given date" do
      now = DateTime.utc_now()
      yesterday = now |> DateTime.add(-1, :day)
      tomorrow = now |> DateTime.add(1, :day)

      Subject.schedule(yesterday)
      Subject.schedule(tomorrow)

      assert 2 == Repo.aggregate(Subject, :count)

      Subject.update_done(now)

      assert 1 == Repo.aggregate(Subject, :count)
    end
  end

  describe "should_update_points?/0" do
    setup do
      now = DateTime.utc_now()
      yesterday = now |> DateTime.add(-1, :day)
      tomorrow = now |> DateTime.add(1, :day)

      {:ok, now: now, yesterday: yesterday, tomorrow: tomorrow}
    end

    test "if any points_update has :next_update_date that is in the past, returns true", %{
      yesterday: yesterday,
      tomorrow: tomorrow
    } do
      Subject.schedule(yesterday)
      Subject.schedule(tomorrow)

      assert true == Subject.should_update_points?()
    end

    test "if points_update has :next_update_date equal to the current date, returns true", %{
      now: now
    } do
      Subject.schedule(now)

      assert true == Subject.should_update_points?()
    end

    test "if all points_updates have :next_update_date that is in the future, returns false", %{
      tomorrow: tomorrow
    } do
      Subject.schedule(tomorrow)

      assert false == Subject.should_update_points?()
    end
  end
end

defmodule Scoreboard.Users.PointsUpdateTest do
  use Scoreboard.DataCase, async: true

  alias Scoreboard.Repo
  alias Scoreboard.Users.PointsUpdate, as: Subject

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

  describe "last_overdue_update/0" do
    setup do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      yesterday = now |> DateTime.add(-1, :day) |> DateTime.truncate(:second)
      tomorrow = now |> DateTime.add(1, :day) |> DateTime.truncate(:second)

      {:ok, now: now, yesterday: yesterday, tomorrow: tomorrow}
    end

    test "if there are many points_updates with :next_update_date in the past, returns the one with the most recent one",
         %{now: now, yesterday: yesterday} do
      Subject.schedule(yesterday)
      Subject.schedule(now)

      assert %Subject{next_update_date: ^now} = Subject.last_overdue_update()
    end

    test "if any points_update has :next_update_date that is in the past, returns it", %{
      yesterday: yesterday,
      tomorrow: tomorrow
    } do
      Subject.schedule(yesterday)
      Subject.schedule(tomorrow)

      assert %Subject{next_update_date: ^yesterday} = Subject.last_overdue_update()
    end

    test "if points_update has :next_update_date equal to the current date, returns it", %{
      now: now
    } do
      Subject.schedule(now)

      assert %Subject{next_update_date: ^now} = Subject.last_overdue_update()
    end

    test "if all points_updates have :next_update_date that is in the future, returns nil", %{
      tomorrow: tomorrow
    } do
      Subject.schedule(tomorrow)

      assert nil == Subject.last_overdue_update()
    end
  end
end

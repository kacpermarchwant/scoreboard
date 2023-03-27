defmodule Scoreboard.Repo.Migrations.PointsUpdates do
  use Ecto.Migration

  def change do
    create table(:points_updates, primary_key: false) do
      add :next_update_date, :utc_datetime, primary_key: true
    end
  end
end

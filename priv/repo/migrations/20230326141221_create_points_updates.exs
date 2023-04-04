defmodule Scoreboard.Repo.Migrations.CreatePointsUpdates do
  use Ecto.Migration

  def change do
    create table(:points_updates, primary_key: false) do
      add :next_update_date, :utc_datetime, primary_key: true
      add :min_value, :integer
      add :max_value, :integer
    end
  end
end

defmodule Scoreboard.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer

      timestamps()
    end

    # If we were to add an index to an existing table,
    # we would need to create index concurrently to not lock the whole table.
    create index(:users, [:points])
  end
end

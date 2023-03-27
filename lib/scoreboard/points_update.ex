defmodule Scoreboard.PointsUpdate do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Scoreboard.Repo

  @primary_key false
  schema "points_updates" do
    field :next_update_date, :utc_datetime, primary_key: true
  end

  def schedule(next_update_date) do
    %{next_update_date: next_update_date}
    |> changeset()
    |> Repo.insert!()

    :ok
  end

  def should_update_points? do
    now = DateTime.utc_now()

    __MODULE__
    # it's a safe check, we don't compare Elixir structs here
    |> where([points_update], points_update.next_update_date <= ^now)
    |> Repo.exists?()
  end

  def update_done(date) do
    from(points_update in __MODULE__, where: points_update.next_update_date <= ^date)
    |> Repo.delete_all()

    :ok
  end

  defp changeset(points_update \\ %__MODULE__{}, attrs) do
    points_update
    |> cast(attrs, [:next_update_date])
    |> validate_required([:next_update_date])
  end
end

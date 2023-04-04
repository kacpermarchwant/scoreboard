defmodule Scoreboard.Users.PointsUpdate do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Scoreboard.Repo
  alias Scoreboard.Users.User

  @primary_key false
  schema "points_updates" do
    field :next_update_date, :utc_datetime, primary_key: true
    field :min_value, :integer
    field :max_value, :integer
  end

  def schedule(
        next_update_date,
        min_value \\ User.min_points_value(),
        max_value \\ User.max_points_value()
      ) do
    %{next_update_date: next_update_date, min_value: min_value, max_value: max_value}
    |> changeset()
    |> Repo.insert!()

    :ok
  end

  def last_overdue_update do
    now = DateTime.utc_now()

    __MODULE__
    |> order_by([points_update], desc: points_update.next_update_date)
    # it's a safe check, we don't compare Elixir structs here
    |> where([points_update], points_update.next_update_date <= ^now)
    |> limit(1)
    |> Repo.one()
  end

  def update_done(date) do
    from(points_update in __MODULE__, where: points_update.next_update_date <= ^date)
    |> Repo.delete_all()

    :ok
  end

  defp changeset(points_update \\ %__MODULE__{}, attrs) do
    points_update
    |> cast(attrs, [:next_update_date, :min_value, :max_value])
    |> validate_required([:next_update_date, :min_value, :max_value])
    |> validate_inclusion(:min_value, User.min_points_value()..User.max_points_value())
    |> validate_inclusion(:max_value, attrs.min_value..User.max_points_value())
  end
end

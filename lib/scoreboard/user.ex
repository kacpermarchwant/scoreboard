defmodule Scoreboard.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Scoreboard.Repo
  alias Scoreboard.PointsUpdate

  schema "users" do
    field :points, :integer

    timestamps()
  end

  def create(params) do
    params
    |> changeset()
    |> Repo.insert()
  end

  # The requirements do not mention anything about the order of the returned users,
  # so the most obvious optimization would be to simply keep store in memory two users with the highest score for a given batch and only work with them,
  # but it's a bit hacky, so I went with a normal query.
  #
  # Plus, it's super fast anyway since we are pretty much guaranteed to fetch the date from the buffer and avoid disk access.
  def get_users_with_more_points_than(min_point) do
    __MODULE__
    |> where([user], user.points > ^min_point)
    |> limit(2)
    |> Repo.all()
  end

  # There is no need for anything more sophisticated than a simple update_all.
  #
  # We don't have any other writes,
  # and it doesn't impact reads (at least not on Read Committed Isolation Level).
  # The number of rows is also relatively low, especially considering how small they are.
  #
  # And eventual batching would introduce problems with complexity
  # which may or may not be acceptable.
  def randomize_points do
    now = DateTime.utc_now()
    # We don't want a transaction here
    :ok = PointsUpdate.schedule(now)

    from(user in __MODULE__,
      update: [
        set: [points: fragment("floor(random() * 100 + 1)"), updated_at: ^DateTime.utc_now()]
      ]
    )
    |> Repo.update_all([])

    :ok = PointsUpdate.update_done(now)

    :ok
  end

  defp changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
  end
end

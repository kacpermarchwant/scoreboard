defmodule Scoreboard.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Scoreboard.Repo
  alias Scoreboard.Users.PointsUpdate

  @min_points_value 0
  @max_points_value 100

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
  # so the most obvious optimization would be to simply store in memory two users with the highest score for a given batch and only work with them,
  # but it's a bit hacky, so I went with a normal query.
  #
  # If app is read-heavy, we can store id in points_index and have `index-only` access
  #
  # But, it's super fast anyway since we are pretty much guaranteed to fetch the date from the buffer and avoid disk access.
  def users_with_more_points_than(min_point) do
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
  def randomize_points(min_value \\ @min_points_value, max_value \\ @max_points_value)

  def randomize_points(min_value, _max_value) when min_value < @min_points_value,
    do: {:error, :min_value_is_too_low}

  def randomize_points(_min_value, max_value) when max_value > @max_points_value,
    do: {:error, :max_value_is_too_high}

  def randomize_points(min_value, max_value) when min_value > max_value,
    do: {:error, :invalid_values}

  def randomize_points(min_value, max_value) do
    now = DateTime.utc_now()
    # We don't want a transaction here
    :ok = PointsUpdate.schedule(now, min_value, max_value)

    from(user in __MODULE__,
      update: [
        set: [
          points:
            fragment(
              "floor(random() * (?::integer - ?::integer + 1) + ?::integer)",
              ^max_value,
              ^min_value,
              ^min_value
            ),
          updated_at: ^DateTime.utc_now()
        ]
      ]
    )
    |> Repo.update_all([])

    :ok = PointsUpdate.update_done(now)

    :ok
  end

  def min_points_value, do: @min_points_value
  def max_points_value, do: @max_points_value

  defp changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
    |> validate_inclusion(:points, @min_points_value..@max_points_value)
  end
end

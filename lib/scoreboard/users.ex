defmodule Scoreboard.Users do
  alias Scoreboard.Users.User
  alias Scoreboard.Users.PointsUpdater

  defdelegate create(params), to: User

  defdelegate users_with_more_points_than(min_point), to: User

  defdelegate min_points_value, to: User

  defdelegate max_points_value, to: User

  defdelegate update_points, to: PointsUpdater
end

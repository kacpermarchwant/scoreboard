defmodule ScoreboardWeb.ScoreboardJSON do
  alias Scoreboard.Users.User

  def home(%{users: users, timestamp: timestamp}) do
    %{users: for(user <- users, do: serialize(user)), timestamp: timestamp}
  end

  defp serialize(%User{} = user) do
    %{
      id: user.id,
      points: user.points
    }
  end
end

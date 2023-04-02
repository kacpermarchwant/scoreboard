defmodule ScoreboardWeb.ScoreboardController do
  use ScoreboardWeb, :controller

  action_fallback ScoreboardWeb.FallbackController

  def home(conn, _params) do
    %{users: users, timestamp: timestamp} = Scoreboard.users_and_timestamp()

    render(conn, :home, users: users, timestamp: timestamp)
  end
end

defmodule ScoreboardWeb.ScoreboardController do
  use ScoreboardWeb, :controller

  action_fallback ScoreboardWeb.FallbackController

  def home(conn, _params) do
    %{users: users, last_query_date: last_query_date} = Scoreboard.get_users_and_last_query_date()

    render(conn, :home, users: users, timestamp: last_query_date)
  end
end

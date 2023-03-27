defmodule Scoreboard do
  defdelegate get_users_and_last_query_date, to: Scoreboard.Server
end

defmodule Scoreboard do
  defdelegate get_users_and_timestamp, to: Scoreboard.Server
end

defmodule Scoreboard do
  defdelegate users_and_timestamp, to: Scoreboard.Server
end

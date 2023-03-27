# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

now =
  NaiveDateTime.utc_now()
  |> NaiveDateTime.truncate(:second)

user_params =
  for _ <- 1..1_000_000 do
    %{
      points: 0,
      inserted_at: now,
      updated_at: now
    }
  end

user_params
|> Enum.chunk_every(10_000)
|> Enum.each(fn batch ->
  Scoreboard.Repo.insert_all(Scoreboard.User, batch)
end)

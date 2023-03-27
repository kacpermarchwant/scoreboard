defmodule Scoreboard.Server do
  use GenServer

  alias Scoreboard.User
  alias Scoreboard.PointsUpdater

  # 1 minute
  @update_interval 1000 * 60

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts ++ [name: __MODULE__])
  end

  def get_users_and_last_query_date do
    GenServer.call(__MODULE__, :get_users)
  end

  @impl true
  def init(_) do
    schedule_update()

    {:ok, %{min_number: generate_min_number(), last_query_date: nil}}
  end

  @impl true
  def handle_call(
        :get_users,
        _from,
        %{min_number: min_number, last_query_date: last_query_date} = state
      ) do
    users = User.get_users_with_more_points_than(min_number)

    {:reply, %{users: users, last_query_date: last_query_date},
     %{state | last_query_date: DateTime.utc_now()}}
  end

  @impl true
  def handle_info(:update, state) do
    PointsUpdater.update_points()
    schedule_update()

    {:noreply, %{state | min_number: generate_min_number()}}
  end

  defp schedule_update do
    Process.send_after(self(), :update, @update_interval)
  end

  defp generate_min_number do
    Enum.random(1..100)
  end
end

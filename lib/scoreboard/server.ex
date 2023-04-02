defmodule Scoreboard.Server do
  @doc """
  I don't do any snapshots of the GenServer state. If the process fails, we lose the session.
  """
  use GenServer

  alias Scoreboard.Users

  @one_minute 1000 * 60

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts ++ [name: __MODULE__])
  end

  def users_and_timestamp do
    GenServer.call(__MODULE__, :get_users_and_timestamp)
  end

  def set_min_number(min_number) do
    GenServer.call(__MODULE__, {:set_min_number, min_number})
  end

  @impl true
  def init(opts \\ []) do
    update_interval = update_interval(opts)

    schedule_update(update_interval, Users.update_points())

    {:ok, %{min_number: generate_min_number(), timestamp: nil}}
  end

  @impl true
  def handle_call(
        :get_users_and_timestamp,
        _from,
        %{min_number: min_number, timestamp: timestamp} = state
      ) do
    users = Users.users_with_more_points_than(min_number)

    {:reply, %{users: users, timestamp: timestamp}, %{state | timestamp: DateTime.utc_now()}}
  end

  @impl true
  def handle_call({:set_min_number, new_min_number}, _from, state) do
    {:reply, :ok, %{state | min_number: new_min_number}}
  end

  @impl true
  def handle_info({:update, update_interval, update_function}, state) do
    update_function.()
    schedule_update(update_interval, update_function)

    {:noreply, %{state | min_number: generate_min_number()}}
  end

  defp schedule_update(
         update_interval,
         update_function
       ) do
    Process.send_after(
      self(),
      {:update, update_interval, update_function},
      update_interval
    )
  end

  defp generate_min_number do
    min_value = Users.min_points_value()
    max_value = Users.max_points_value()
    Enum.random(min_value..max_value)
  end

  defp update_interval(nil), do: @one_minute
  defp update_interval(opts), do: Keyword.get(opts, :update_interval, update_interval(nil))
end

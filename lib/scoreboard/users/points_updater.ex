defmodule Scoreboard.Users.PointsUpdater do
  @moduledoc """
  I want to run the update on a separate process and there are a few reasons for that:

  1. We want the operation to be async to not block the caller.
  2. The database can fail, so we need a retry mechanism to ensure data integrity.
  3. The process of updating points is hidden behind the interface.

  The abstraction is rather awkward and leaks the implementation details (you can see that clearly in tests),
  but I didn't want to set up a full-blown job scheduler for a take-home assignment.
  """
  use GenServer

  alias Scoreboard.Users.User
  alias Scoreboard.Users.PointsUpdate

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts ++ [name: __MODULE__])
  end

  # It's not a proper outbox pattern, we should insert points_update before returning
  # otherwise we don't have a guarantee that the update will actually happen
  def update_points() do
    # we want this call to be async, to not block the caller
    GenServer.cast(__MODULE__, {:update_points, User.randomize_points()})

    :ok
  end

  @impl true
  def init(_) do
    case PointsUpdate.last_overdue_update() do
      nil -> :ok
      %{min_value: min_value, max_value: max_value} -> User.randomize_points(min_value, max_value)
    end

    {:ok, %{}}
  end

  @impl true
  def handle_cast({:update_points, update_function}, state) do
    update_function.()

    {:noreply, state}
  end
end

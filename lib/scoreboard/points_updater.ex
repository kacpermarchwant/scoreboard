defmodule Scoreboard.PointsUpdater do
  @moduledoc """
  I want to run the update on a separate process. There are a few reasons for that:

  We want the operation to be async to not block the caller.
  The database can fail, so we need a retry mechanism to ensure data integrity.
  The process of updating points is hidden behind the interface.

  The abstraction is rather awkward and leaks the implementation details (you can see that clearly in tests), but I didn't want to set up a full-blown job scheduler for a take-home assignment.
  """
  use GenServer

  alias Scoreboard.User
  alias Scoreboard.PointsUpdate

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts ++ [name: __MODULE__])
  end

  def update_points do
    # we want this call to be async, to not block the caller
    GenServer.cast(__MODULE__, :update_points)

    :ok
  end

  @impl true
  def init(_) do
    if PointsUpdate.should_update_points?() do
      User.randomize_points()
    end

    {:ok, %{}}
  end

  @impl true
  def handle_cast(:update_points, state) do
    User.randomize_points()

    {:noreply, state}
  end
end

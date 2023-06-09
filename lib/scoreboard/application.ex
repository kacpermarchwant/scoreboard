defmodule Scoreboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Telemetry supervisor
        ScoreboardWeb.Telemetry,
        # Start the Ecto repository
        Scoreboard.Repo,
        # Start the PubSub system
        {Phoenix.PubSub, name: Scoreboard.PubSub},
        # Start the Endpoint (http/https)
        ScoreboardWeb.Endpoint
        # Start a worker by calling: Scoreboard.Worker.start_link(arg)
      ] ++ workers(Application.fetch_env!(:scoreboard, :env))

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Scoreboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScoreboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp workers(:test), do: []

  defp workers(_env) do
    [Scoreboard.Users.PointsUpdater, Scoreboard.Server]
  end
end

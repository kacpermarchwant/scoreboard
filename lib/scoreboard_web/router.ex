defmodule ScoreboardWeb.Router do
  use ScoreboardWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ScoreboardWeb do
    pipe_through :api

    get "/", ScoreboardController, :home
  end
end

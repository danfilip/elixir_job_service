defmodule JobServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: JobServer.Worker.start_link(arg)
      # {JobServer.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: JobServer.Endpoint,
        options: [port: 2345]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule BjjLib.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BjjLibWeb.Telemetry,
      BjjLib.Repo,
      {DNSCluster, query: Application.get_env(:bjj_lib, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BjjLib.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BjjLib.Finch},
      # Start a worker by calling: BjjLib.Worker.start_link(arg)
      # {BjjLib.Worker, arg},
      # Start to serve requests, typically the last entry
      BjjLibWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BjjLib.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BjjLibWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

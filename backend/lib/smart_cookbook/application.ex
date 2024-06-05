defmodule SmartCookbook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SmartCookbookWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:smart_cookbook, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SmartCookbook.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SmartCookbook.Finch},
      # Start a worker by calling: SmartCookbook.Worker.start_link(arg)
      # {SmartCookbook.Worker, arg},
      # Start to serve requests, typically the last entry
      SmartCookbookWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmartCookbook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SmartCookbookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

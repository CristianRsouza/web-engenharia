defmodule AppPf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AppPfWeb.Telemetry,
      AppPf.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:app_pf, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:app_pf, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AppPf.PubSub},
      # Start a worker by calling: AppPf.Worker.start_link(arg)
      # {AppPf.Worker, arg},
      # Start to serve requests, typically the last entry
      AppPfWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AppPf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AppPfWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end

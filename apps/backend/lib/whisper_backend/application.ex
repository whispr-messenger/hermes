defmodule WhisperBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Assurez-vous que Postgrex.TypeManager est démarré avant le Repo
      {Postgrex, Application.get_env(:whisper_backend, WhisperBackend.Repo)},
      WhisperBackendWeb.Telemetry,
      WhisperBackend.Repo,
      {DNSCluster, query: Application.get_env(:whisper_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WhisperBackend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WhisperBackend.Finch},
      # Start a worker by calling: WhisperBackend.Worker.start_link(arg)
      # {WhisperBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      WhisperBackendWeb.Endpoint,
      # Ajouter la connexion Redis avec la configuration correcte
      {Redix, Application.get_env(:whisper_backend, :redis)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WhisperBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhisperBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

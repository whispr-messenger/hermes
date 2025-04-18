defmodule WhisperBackend.Repo do
  use Ecto.Repo,
    otp_app: :whisper_backend,
    adapter: Ecto.Adapters.Postgres
end

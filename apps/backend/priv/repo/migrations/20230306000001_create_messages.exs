defmodule WhisperBackend.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :sender_id, references(:users, on_delete: :nothing)
      add :recipient_id, references(:users, on_delete: :nothing)
      add :read, :boolean, default: false, null: false
      add :media_url, :string
      add :media_type, :string
      add :media_hash, :string

      timestamps()
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:recipient_id])
  end
end
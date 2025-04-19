defmodule WhisperBackend.Repo.Migrations.AddForeignKeysToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :sender_id, references(:users, on_delete: :nothing)
      modify :recipient_id, references(:users, on_delete: :nothing)
    end
  end
end

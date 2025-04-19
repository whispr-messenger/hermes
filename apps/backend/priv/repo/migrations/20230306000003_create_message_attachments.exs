defmodule WhisperBackend.Repo.Migrations.CreateMessageAttachments do
  use Ecto.Migration

  def change do
    create table(:message_attachments) do
      add :message_id, references(:messages, on_delete: :delete_all)
      add :media_url, :string
      add :media_type, :string
      add :media_hash, :string
      add :filename, :string
      add :content_type, :string
      add :file_size, :integer

      timestamps()
    end

    create index(:message_attachments, [:message_id])
    create index(:message_attachments, [:media_hash])
  end
end
defmodule WhisperBackend.Repo.Migrations.CreateMediaFiles do
  # No changes needed to the content
  use Ecto.Migration

  def change do
    create table(:media_files) do
      add :filename, :string, null: false
      add :original_filename, :string, null: false
      add :content_type, :string, null: false
      add :media_type, :string, null: false
      add :file_size, :integer
      add :media_hash, :string
      add :status, :string, default: "pending"
      add :rejection_reason, :string
      add :metadata, :map, default: %{}
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:media_files, [:user_id])
    create index(:media_files, [:media_hash])
    create index(:media_files, [:status])
  end
end
defmodule WhisperBackend.Repo.Migrations.CreateGroupMessages do
  use Ecto.Migration

  def change do
    create table(:group_messages) do
      add :content, :text
      add :user_id, references(:users, on_delete: :nilify_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :media_url, :string
      add :media_type, :string
      add :media_hash, :string

      timestamps()
    end

    create index(:group_messages, [:user_id])
    create index(:group_messages, [:group_id])
  end
end
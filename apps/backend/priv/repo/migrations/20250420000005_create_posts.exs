defmodule WhisperBackend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :content, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :visibility, :string, default: "public", null: false # public, friends, private
      add :status, :string, default: "active", null: false # active, moderated, deleted

      timestamps()
    end

    create index(:posts, [:user_id])
    create index(:posts, [:visibility])
  end
end
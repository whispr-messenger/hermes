defmodule WhisperBackend.Repo.Migrations.CreatePostMedia do
  use Ecto.Migration

  def change do
    create table(:post_media) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :media_id, references(:media_files, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:post_media, [:post_id])
    create index(:post_media, [:media_id])
    create unique_index(:post_media, [:post_id, :media_id], name: :post_media_post_id_media_id_index)
  end
end
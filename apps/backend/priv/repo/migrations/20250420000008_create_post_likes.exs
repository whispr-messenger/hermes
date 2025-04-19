defmodule WhisperBackend.Repo.Migrations.CreatePostLikes do
  use Ecto.Migration

  def change do
    create table(:post_likes) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nilify_all), null: false

      timestamps()
    end

    create index(:post_likes, [:post_id])
    create index(:post_likes, [:user_id])
    create unique_index(:post_likes, [:post_id, :user_id], name: :post_likes_post_id_user_id_index)
  end
end
defmodule WhisperBackend.Repo.Migrations.CreatePostReports do
  use Ecto.Migration

  def change do
    create table(:post_reports) do
      add :reason, :string, null: false
      add :status, :string, default: "pending", null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :reporter_id, references(:users, on_delete: :nilify_all), null: false

      timestamps()
    end

    create index(:post_reports, [:post_id])
    create index(:post_reports, [:reporter_id])
    create index(:post_reports, [:status])
  end
end
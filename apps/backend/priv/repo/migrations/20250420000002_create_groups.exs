defmodule WhisperBackend.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string, null: false
      add :description, :text
      add :avatar_url, :string
      add :owner_id, references(:users, on_delete: :nilify_all), null: false
      add :is_private, :boolean, default: false, null: false

      timestamps()
    end

    create index(:groups, [:owner_id])
    create index(:groups, [:name])
  end
end
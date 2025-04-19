defmodule WhisperBackend.Repo.Migrations.CreateGroupMemberships do
  use Ecto.Migration

  def change do
    create table(:group_memberships) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :role, :string, default: "member", null: false # member, moderator, admin
      add :status, :string, default: "pending", null: false # pending, accepted, rejected

      timestamps()
    end

    create index(:group_memberships, [:user_id])
    create index(:group_memberships, [:group_id])
    create unique_index(:group_memberships, [:user_id, :group_id], name: :unique_group_membership)
  end
end
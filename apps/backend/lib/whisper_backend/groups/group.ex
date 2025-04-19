defmodule WhisperBackend.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :description, :string
    field :avatar_url, :string
    field :is_private, :boolean, default: false
    belongs_to :owner, WhisperBackend.Accounts.User, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description, :avatar_url, :owner_id, :is_private])
    |> validate_required([:name, :owner_id])
  end
end
defmodule WhisperBackend.Social.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friendships" do
    field :status, :string, default: "pending" # pending, accepted, rejected
    belongs_to :user, WhisperBackend.Accounts.User
    belongs_to :friend, WhisperBackend.Accounts.User, foreign_key: :friend_id

    timestamps()
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:user_id, :friend_id, :status])
    |> validate_required([:user_id, :friend_id, :status])
    |> unique_constraint([:user_id, :friend_id])
  end
end
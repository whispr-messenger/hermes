defmodule WhisperBackend.Social.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :visibility, :string, default: "public" # public, friends, private
    field :status, :string, default: "active" # active, moderated, deleted
    belongs_to :user, WhisperBackend.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :user_id, :visibility, :status])
    |> validate_required([:content, :user_id])
  end
end
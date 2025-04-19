defmodule WhisperBackend.Social.PostComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_comments" do
    field :content, :string
    belongs_to :post, WhisperBackend.Social.Post
    belongs_to :user, WhisperBackend.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :post_id, :user_id])
    |> validate_required([:content, :post_id, :user_id])
  end
end
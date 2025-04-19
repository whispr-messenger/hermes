defmodule WhisperBackend.Social.PostMedia do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_media" do
    belongs_to :post, WhisperBackend.Social.Post
    belongs_to :media, WhisperBackend.Media.MediaFile

    timestamps()
  end

  @doc false
  def changeset(post_media, attrs) do
    post_media
    |> cast(attrs, [:post_id, :media_id])
    |> validate_required([:post_id, :media_id])
    |> unique_constraint([:post_id, :media_id])
  end
end
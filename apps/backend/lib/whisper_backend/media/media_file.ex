defmodule WhisperBackend.Media.MediaFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "media_files" do
    field :filename, :string
    field :original_filename, :string
    field :content_type, :string
    field :media_type, :string
    field :file_size, :integer
    field :media_hash, :string
    field :status, :string, default: "pending"
    field :rejection_reason, :string
    field :metadata, :map, default: %{}
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(media_file, attrs) do
    media_file
    |> cast(attrs, [:filename, :original_filename, :content_type, :media_type, :file_size, :media_hash, :status, :rejection_reason, :metadata, :user_id])
    |> validate_required([:filename, :content_type, :media_type, :user_id])
  end
end
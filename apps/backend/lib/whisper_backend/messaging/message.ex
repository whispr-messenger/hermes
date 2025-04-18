defmodule WhisperBackend.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :sender_id, :id
    field :recipient_id, :id
    field :read, :boolean, default: false
    field :media_url, :string
    field :media_type, :string
    field :media_hash, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :sender_id, :recipient_id, :read, :media_url, :media_type, :media_hash])
    |> validate_required([:content, :sender_id, :recipient_id])
  end
end
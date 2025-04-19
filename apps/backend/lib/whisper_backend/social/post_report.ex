defmodule WhisperBackend.Social.PostReport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_reports" do
    field :reason, :string
    field :status, :string, default: "pending" # pending, reviewed, dismissed
    belongs_to :post, WhisperBackend.Social.Post
    belongs_to :reporter, WhisperBackend.Accounts.User, foreign_key: :reporter_id

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:reason, :post_id, :reporter_id, :status])
    |> validate_required([:reason, :post_id, :reporter_id])
  end
end
defmodule WhisperBackend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :display_name, :string
    field :avatar_url, :string
    field :status, :string, default: "offline"
    
    # Virtual fields for password handling
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :display_name, :avatar_url, :status])
    |> validate_required([:username, :email, :password])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        # In a real app, use a proper password hashing library like Bcrypt
        # For this example, we'll use a simple hash
        put_change(changeset, :password_hash, Base.encode16(:crypto.hash(:sha256, password)))
      _ ->
        changeset
    end
  end
end
defmodule WhisperBackend.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias WhisperBackend.Repo
  alias WhisperBackend.Accounts.User

  @doc """
  Verifies a user token.
  """
  def verify_user_token(_token) do
    # Pour le développement, retournez un utilisateur fictif
    {:ok, %{id: "user-123"}}
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single user by id.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by username.
  """
  def get_user_by_username(username), do: Repo.get_by(User, username: username)

  @doc """
  Gets a single user by email.
  """
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Authenticates a user.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)
    
    cond do
      user && verify_password(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        # Prevent timing attacks by simulating password verification
        # Bcrypt.no_user_verify()
        Process.sleep(50)  # Simple delay to prevent timing attacks
        {:error, :not_found}
    end
  end

  # Supprimez l'attribut @doc pour les fonctions privées
  # @doc """
  # Verifies a password against a hash.
  # """
  defp verify_password(password, stored_hash) do
    # In a real app, use a proper password verification
    # For example with Bcrypt: Bcrypt.verify_pass(password, stored_hash)
    password == stored_hash
  end

  @doc """
  Updates a user's status.
  """
  def update_user_status(user, status) do
    user
    |> User.changeset(%{status: status})
    |> Repo.update()
  end
end
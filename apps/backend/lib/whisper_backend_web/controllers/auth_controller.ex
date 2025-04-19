defmodule WhisperBackendWeb.AuthController do
  use WhisperBackendWeb, :controller
  
  alias WhisperBackend.Accounts
  
  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        token = generate_token(user)
        
        conn
        |> put_status(:created)
        |> render(:register, user: user, token: token)
        
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
  
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = generate_token(user)
        
        conn
        |> put_status(:ok)
        |> render("login.json", %{user: user, token: token})
        
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: "Invalid email or password")
    end
  end
  
  defp generate_token(user) do
    # In a real app, use a proper token generation library like Guardian
    # For this example, we'll use a simple token
    "user-token-#{user.id}"
  end
end
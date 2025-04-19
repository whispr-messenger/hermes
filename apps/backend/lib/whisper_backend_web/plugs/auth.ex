defmodule WhisperBackendWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller
  
  alias WhisperBackend.Accounts
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Accounts.verify_user_token(token) do
      assign(conn, :user_id, user.id)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> put_view(WhisperBackendWeb.ErrorView)
        |> render("401.json", message: "Unauthorized")
        |> halt()
    end
  end
end
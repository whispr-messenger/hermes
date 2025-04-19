defmodule WhisperBackendWeb.MessageChannel do
  use Phoenix.Channel
  alias WhisperBackend.Redis

  def join("messages:" <> user_id, _params, socket) do
    if socket.assigns.user_id == user_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_message", %{"recipient_id" => recipient_id, "content" => content}, socket) do
    user_id = socket.assigns.user_id
    
    message = %{
      id: Ecto.UUID.generate(),
      sender_id: user_id,
      recipient_id: recipient_id,
      content: content,
      timestamp: DateTime.utc_now() |> DateTime.to_unix()
    }
    
    # Stocker le message dans Redis
    Redis.store_message(user_id, recipient_id, message)
    
    # Diffuser le message aux utilisateurs concernés
    WhisperBackendWeb.Endpoint.broadcast("messages:#{recipient_id}", "new_message", message)
    
    {:reply, {:ok, message}, socket}
  end
end
defmodule WhisperBackendWeb.ChatChannel do
  use Phoenix.Channel
  # Supprimez les alias non utilisés ou commentez-les si vous prévoyez de les utiliser plus tard
  # alias WhisperBackend.Messaging
  # alias WhisperBackend.Accounts

  def join("chat:" <> _chat_id, _params, socket) do
    # Préfixez chat_id avec un underscore pour indiquer qu'il n'est pas utilisé
    # Ici, vous pourriez vérifier si l'utilisateur est membre du chat
    # Pour l'instant, nous autorisons simplement la connexion
    {:ok, socket}
  end

  def handle_in("new_message", %{"content" => content} = params, socket) do
    user_id = socket.assigns.user_id
    "chat:" <> chat_id = socket.topic
    
    # Ici, vous pourriez sauvegarder le message dans une table de messages de groupe
    # Pour l'instant, nous diffusons simplement le message
    message_data = %{
      sender_id: user_id,
      content: content,
      chat_id: chat_id,
      inserted_at: DateTime.utc_now(),
      media_url: params["media_url"],
      media_type: params["media_type"]
    }
    
    broadcast!(socket, "new_message", message_data)
    {:reply, :ok, socket}
  end

  def handle_in("user_typing", _params, socket) do
    user_id = socket.assigns.user_id
    broadcast_from!(socket, "user_typing", %{user_id: user_id})
    {:noreply, socket}
  end
end
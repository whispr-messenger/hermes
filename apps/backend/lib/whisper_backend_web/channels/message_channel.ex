defmodule WhisperBackendWeb.MessageChannel do
  use Phoenix.Channel
  alias WhisperBackend.Messaging
  # Supprimez l'alias non utilisé ou commentez-le si vous prévoyez de l'utiliser plus tard
  # alias WhisperBackend.Accounts

  def join("messages:" <> user_id, _params, socket) do
    if socket.assigns.user_id == user_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_message", %{"recipient_id" => recipient_id, "content" => content} = params, socket) do
    sender_id = socket.assigns.user_id
    
    message_params = %{
      sender_id: sender_id,
      recipient_id: recipient_id,
      content: content,
      media_url: params["media_url"],
      media_type: params["media_type"],
      media_hash: params["media_hash"]
    }
    
    case Messaging.create_message(message_params) do
      {:ok, message} ->
        message_data = %{
          id: message.id,
          content: message.content,
          sender_id: message.sender_id,
          recipient_id: message.recipient_id,
          inserted_at: message.inserted_at,
          media_url: message.media_url,
          media_type: message.media_type
        }
        
        # Broadcast to the recipient's channel
        WhisperBackendWeb.Endpoint.broadcast("messages:#{recipient_id}", "new_message", message_data)
        
        {:reply, {:ok, message_data}, socket}
        
      {:error, _changeset} ->
        {:reply, {:error, %{reason: "could not save message"}}, socket}
    end
  end

  def handle_in("mark_as_read", %{"message_id" => message_id}, socket) do
    user_id = socket.assigns.user_id
    
    case Messaging.mark_as_read(message_id, user_id) do
      {:ok, _message} ->
        {:reply, :ok, socket}
        
      {:error, _reason} ->
        {:reply, {:error, %{reason: "could not mark message as read"}}, socket}
    end
  end

  def handle_in("get_messages", %{"other_user_id" => other_user_id}, socket) do
    user_id = socket.assigns.user_id
    
    messages = Messaging.get_conversation(user_id, other_user_id)
    |> Enum.map(fn message ->
      %{
        id: message.id,
        content: message.content,
        sender_id: message.sender_id,
        recipient_id: message.recipient_id,
        read: message.read,
        inserted_at: message.inserted_at,
        media_url: message.media_url,
        media_type: message.media_type
      }
    end)
    
    {:reply, {:ok, %{messages: messages}}, socket}
  end
end
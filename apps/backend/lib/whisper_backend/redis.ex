defmodule WhisperBackend.Redis do
  @moduledoc """
  Module pour gérer les interactions avec Redis.
  """

  @doc """
  Démarre une connexion Redis.
  """
  def start_link do
    config = Application.get_env(:whisper_backend, :redis)
    
    if config[:url] do
      Redix.start_link(config[:url], name: :redix)
    else
      Redix.start_link(
        host: config[:host],
        port: config[:port],
        name: :redix
      )
    end
  end

  @doc """
  Stocke un message dans Redis.
  """
  def store_message(sender_id, recipient_id, message) do
    message_json = Jason.encode!(message)
    
    # Stocker le message dans les deux conversations
    Redix.command(:redix, ["LPUSH", "messages:#{sender_id}:#{recipient_id}", message_json])
    Redix.command(:redix, ["LPUSH", "messages:#{recipient_id}:#{sender_id}", message_json])
    
    # Publier le message pour les abonnés
    Redix.command(:redix, ["PUBLISH", "new_message", message_json])
  end

  @doc """
  Récupère les messages d'une conversation.
  """
  def get_conversation_messages(user_id, other_user_id, limit \\ 50) do
    case Redix.command(:redix, ["LRANGE", "messages:#{user_id}:#{other_user_id}", 0, limit - 1]) do
      {:ok, messages} ->
        {:ok, Enum.map(messages, &Jason.decode!/1)}
      error ->
        error
    end
  end

  @doc """
  Marque les messages comme lus.
  """
  def mark_messages_as_read(user_id, other_user_id) do
    # Implémentation pour marquer les messages comme lus
    # Cela pourrait être fait en stockant un timestamp de dernière lecture
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    Redix.command(:redix, ["SET", "read:#{user_id}:#{other_user_id}", timestamp])
  end
end
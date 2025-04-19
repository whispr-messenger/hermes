defmodule WhisperBackend.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias WhisperBackend.Repo
  alias WhisperBackend.Messaging.Message

  @doc """
  Creates a message.
  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single message.
  """
  def get_message(id), do: Repo.get(Message, id)

  @doc """
  Marks a message as read.
  """
  def mark_as_read(message_id, user_id) do
    message = get_message(message_id)
    
    if message && message.recipient_id == user_id do
      message
      |> Message.changeset(%{read: true})
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Gets all messages between two users.
  """
  def get_conversation(user_id1, user_id2) do
    query = from m in Message,
            where: (m.sender_id == ^user_id1 and m.recipient_id == ^user_id2) or
                   (m.sender_id == ^user_id2 and m.recipient_id == ^user_id1),
            order_by: [asc: m.inserted_at]
            
    Repo.all(query)
  end

  @doc """
  Gets all unread messages for a user.
  """
  def get_unread_messages(user_id) do
    query = from m in Message,
            where: m.recipient_id == ^user_id and m.read == false,
            order_by: [desc: m.inserted_at]
            
    Repo.all(query)
  end

  @doc """
  Gets the count of unread messages for a user from another user.
  """
  def get_unread_count(recipient_id, sender_id) do
    query = from m in Message,
            where: m.recipient_id == ^recipient_id and 
                   m.sender_id == ^sender_id and 
                   m.read == false,
            select: count(m.id)
            
    Repo.one(query)
  end
end
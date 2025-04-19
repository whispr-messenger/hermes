defmodule WhisperBackendWeb.UserSocket do
  use Phoenix.Socket

  # Définir le canal pour les messages
  channel "messages:*", WhisperBackendWeb.MessageChannel

  # Channels
  channel "chat:*", WhisperBackendWeb.ChatChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    # Utiliser le résultat de verify_user_token directement
    # Puisque la fonction retourne toujours {:ok, user_id} pour le moment
    {:ok, user} = WhisperBackend.Accounts.verify_user_token(token)
    {:ok, assign(socket, :user_id, user.id)}
  end

  # Si aucun token n'est fourni
  def connect(_params, _socket, _connect_info) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     WhisperBackendWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
defmodule WhisperBackendWeb.ModerationChannel do
  use WhisperBackendWeb, :channel
  alias WhisperBackend.Media.ContentModeration

  def join("moderation:queue", _payload, socket) do
    # Vérifier si l'utilisateur est un modérateur
    if socket.assigns.user && socket.assigns.user.role == "moderator" do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("moderate", %{"media_id" => media_id, "action" => action}, socket) do
    # Traiter l'action de modération
    case action do
      "approve" ->
        # Approuver le média
        ContentModeration.approve_media(media_id)
        {:reply, :ok, socket}
      "reject" ->
        # Rejeter le média
        ContentModeration.reject_media(media_id)
        {:reply, :ok, socket}
      _ ->
        {:reply, {:error, %{reason: "invalid_action"}}, socket}
    end
  end
end
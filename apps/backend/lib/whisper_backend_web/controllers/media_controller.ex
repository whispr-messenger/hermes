defmodule WhisperBackendWeb.MediaController do
  use WhisperBackendWeb, :controller

  alias WhisperBackend.Media
  alias WhisperBackend.Media.MediaFile

  action_fallback WhisperBackendWeb.FallbackController

  def index(conn, _params) do
    # Récupérer l'ID de l'utilisateur à partir du token JWT
    user_id = conn.assigns.current_user.id
    media_files = Media.get_user_media_files(user_id)
    render(conn, :index, media_files: media_files)
  end

  def create(conn, %{"media" => media_params}) do
    # Récupérer l'ID de l'utilisateur à partir du token JWT
    user_id = conn.assigns.current_user.id
    
    with {:ok, %MediaFile{} = media_file} <- Media.upload_media(media_params, user_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/media/#{media_file}")
      |> render(:show, media_file: media_file)
    end
  end

  def show(conn, %{"id" => id}) do
    # Récupérer l'ID de l'utilisateur à partir du token JWT
    user_id = conn.assigns.current_user.id
    
    media_file = Media.get_media_file(id)
    
    if media_file && (media_file.user_id == user_id || media_file.public) do
      render(conn, :show, media_file: media_file)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Media file not found"})
    end
  end

  def delete(conn, %{"id" => id}) do
    # Récupérer l'ID de l'utilisateur à partir du token JWT
    user_id = conn.assigns.current_user.id
    
    with {:ok, %MediaFile{}} <- Media.delete_media_file(id, user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
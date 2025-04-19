defmodule WhisperBackendWeb.MediaController do
  use WhisperBackendWeb, :controller
  
  alias WhisperBackend.Media
  
  def upload(conn, %{"file" => file_params}) do
    user_id = conn.assigns.user_id
    
    case Media.upload_media(file_params, user_id) do
      {:ok, media_file} ->
        conn
        |> put_status(:created)
        |> render(:show, media_file: media_file)
        
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, reason: reason)
    end
  end
  
  def show(conn, %{"id" => id}) do
    media_file = Media.get_media_file(id)
    
    if media_file do
      conn
      |> put_resp_content_type(media_file.content_type)
      |> send_file(200, "uploads/#{media_file.filename}")
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", reason: "Media file not found")
    end
  end
  
  def delete(conn, %{"id" => id}) do
    user_id = conn.assigns.user_id
    
    case Media.delete_media_file(id, user_id) do
      {:ok, _} ->
        conn
        |> put_status(:no_content)
        |> send_resp(:no_content, "")
        
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", reason: reason)
    end
  end
end
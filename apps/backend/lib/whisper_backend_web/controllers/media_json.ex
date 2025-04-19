defmodule WhisperBackendWeb.MediaJSON do
  # Supprimez cette ligne
  # alias WhisperBackendWeb.Router.Helpers, as: Routes
  
  def show(%{media_file: media_file}) do
    %{
      id: media_file.id,
      filename: media_file.filename,
      content_type: media_file.content_type,
      media_type: media_file.media_type,
      status: media_file.status,
      url: "/api/media/#{media_file.id}"
    }
  end
  
  def index(%{media_files: media_files}) do
    %{
      data: for(media_file <- media_files, do: data(media_file))
    }
  end
  
  defp data(media_file) do
    %{
      id: media_file.id,
      filename: media_file.filename,
      content_type: media_file.content_type,
      media_type: media_file.media_type,
      status: media_file.status,
      # Utiliser une URL simple au lieu de Routes.media_url
      url: "/api/media/#{media_file.id}"
    }
  end
  
  def error(%{reason: reason}) do
    %{
      error: reason
    }
  end
end
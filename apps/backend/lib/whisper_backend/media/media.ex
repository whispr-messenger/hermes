defmodule WhisperBackend.Media do
  @moduledoc """
  The Media context.
  Handles media file uploads, processing, and content moderation.
  """

  import Ecto.Query, warn: false
  alias WhisperBackend.Repo
  alias WhisperBackend.Media.MediaFile
  # Utilisons l'alias correctement dans la fonction moderate_content
  alias WhisperBackend.Media.ContentModeration

  @doc """
  Uploads a media file and processes it.
  """
  def upload_media(params, user_id) do
    # Create a media file record
    with {:ok, media_file} <- create_media_file(params, user_id),
         {:ok, media_file} <- process_media(media_file),
         {:ok, media_file} <- moderate_content(media_file) do
      {:ok, media_file}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Creates a media file record.
  """
  def create_media_file(%{filename: filename, content_type: content_type, path: path}, user_id) do
    # Generate a unique filename
    unique_filename = "#{user_id}_#{:os.system_time(:millisecond)}_#{filename}"
    
    # Determine media type from content_type
    media_type = get_media_type(content_type)
    
    # Create the media file record
    %MediaFile{}
    |> MediaFile.changeset(%{
      filename: unique_filename,
      original_filename: filename,
      content_type: content_type,
      media_type: media_type,
      user_id: user_id,
      status: "pending",
      file_size: File.stat!(path).size
    })
    |> Repo.insert()
  end

  @doc """
  Processes the media file (resize, compress, etc.).
  """
  def process_media(media_file) do
    # This would be implemented with a library like ImageMagick or FFmpeg
    # For now, we'll just simulate processing
    
    # Update the media file status
    media_file
    |> MediaFile.changeset(%{status: "processed"})
    |> Repo.update()
  end

  @doc """
  Moderates the content of the media file.
  """
  def moderate_content(media_file) do
    # Check if the media file contains inappropriate content
    case ContentModeration.check_content(media_file) do
      :ok ->
        # Update the media file status
        media_file
        |> MediaFile.changeset(%{status: "approved"})
        |> Repo.update()
        
      {:error, reason} ->
        # Update the media file status
        media_file
        |> MediaFile.changeset(%{status: "rejected", rejection_reason: reason})
        |> Repo.update()
    end
  end

  @doc """
  Gets a media file by ID.
  """
  def get_media_file(id), do: Repo.get(MediaFile, id)

  @doc """
  Gets all media files for a user.
  """
  def get_user_media_files(user_id) do
    query = from m in MediaFile,
            where: m.user_id == ^user_id,
            order_by: [desc: m.inserted_at]
            
    Repo.all(query)
  end

  @doc """
  Deletes a media file.
  """
  def delete_media_file(id, user_id) do
    media_file = get_media_file(id)
    
    if media_file && media_file.user_id == user_id do
      # Delete the file from storage
      delete_file_from_storage(media_file)
      
      # Delete the record
      Repo.delete(media_file)
    else
      {:error, :unauthorized}
    end
  end

  # Suppression de l'attribut @doc pour la fonction privée
  defp delete_file_from_storage(_media_file) do
    # This would delete the file from your storage system
    # For now, we'll just return :ok
    :ok
  end

  # Remove @doc for private functions
  defp get_media_type(content_type) do
    cond do
      String.starts_with?(content_type, "image/") -> "image"
      String.starts_with?(content_type, "video/") -> "video"
      String.starts_with?(content_type, "audio/") -> "audio"
      true -> "other"
    end
  end

  @doc """
  Generates a hash for a media file for content comparison.
  """
  def generate_media_hash(path) do
    # This would generate a perceptual hash for the file
    # For now, we'll just return a random hash
    :crypto.hash(:sha256, File.read!(path))
    |> Base.encode16(case: :lower)
  end
end
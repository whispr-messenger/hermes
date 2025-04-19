defmodule WhisperBackendWeb.AuthJSON do
  # Importez les helpers nécessaires
  import WhisperBackendWeb.ErrorHelpers
  
  # Fonctions pour formater les réponses JSON
  def register(%{user: user, token: token}) do
    %{
      status: "success",
      data: %{
        user: %{
          id: user.id,
          username: user.username,
          email: user.email,
          display_name: user.display_name,
          avatar_url: user.avatar_url,
          status: user.status
        },
        token: token
      }
    }
  end
  
  def login(%{user: user, token: token}) do
    %{
      status: "success",
      data: %{
        user: %{
          id: user.id,
          username: user.username,
          email: user.email,
          display_name: user.display_name,
          avatar_url: user.avatar_url,
          status: user.status
        },
        token: token
      }
    }
  end
  
  def error(%{changeset: changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    
    %{
      status: "error",
      errors: errors
    }
  end
  
  def error(%{message: message}) do
    %{
      status: "error",
      message: message
    }
  end
end
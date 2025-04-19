defmodule WhisperBackendWeb.Router do
  use WhisperBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :accepts, ["json"]
    # Ajoutez un plug pour vérifier l'authentification
    # plug WhisperBackendWeb.Plugs.Auth
  end

  scope "/api", WhisperBackendWeb do
    pipe_through :api
    
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  # Ajouter dans le scope "/api" qui utilise le pipeline :api
  scope "/api", WhisperBackendWeb do
    pipe_through [:api, :auth]  # Assurez-vous que :auth est défini pour vérifier le JWT

    # Routes existantes...
    
    resources "/media", MediaController, except: [:new, :edit, :update]
    get "/media/:id/download", MediaController, :download
  end
  
  # Si vous avez besoin de routes de développement, utilisez ceci à la place :
  if Mix.env() == :dev do
    scope "/dev", WhisperBackendWeb do
      pipe_through :api
      
      # Routes de développement ici
    end
  end
end

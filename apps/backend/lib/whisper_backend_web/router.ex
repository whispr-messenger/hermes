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

  scope "/api", WhisperBackendWeb do
    pipe_through :auth
    
    # Routes pour les médias
    post "/media/upload", MediaController, :upload
    get "/media/:id", MediaController, :show
    delete "/media/:id", MediaController, :delete
    
    # Autres routes protégées
  end

  # Remplacez cette partie qui cause l'erreur
  # scope "/dev" do
  #   ...
  # end
  
  # Si vous avez besoin de routes de développement, utilisez ceci à la place :
  if Mix.env() == :dev do
    scope "/dev", WhisperBackendWeb do
      pipe_through :api
      
      # Routes de développement ici
    end
  end
end

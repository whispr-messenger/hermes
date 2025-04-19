defmodule WhisperBackend.Repo.Migrations.UpdateMediaFilesTable do
  # Content updated as shown above
  use Ecto.Migration

  def change do
    # First check if the media_files table exists
    execute "DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'media_files') THEN
        -- Ajout d'un index pour améliorer les performances de recherche
        CREATE INDEX media_files_original_filename_index ON media_files (original_filename);
        
        -- Ajout de champs pour stocker des informations supplémentaires
        ALTER TABLE media_files 
        ADD COLUMN IF NOT EXISTS processing_info jsonb DEFAULT '{}'::jsonb,
        ADD COLUMN IF NOT EXISTS public boolean DEFAULT false,
        ADD COLUMN IF NOT EXISTS download_count integer DEFAULT 0;
      END IF;
    END
    $$;";
  end
end

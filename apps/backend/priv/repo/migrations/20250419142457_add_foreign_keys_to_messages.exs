defmodule WhisperBackend.Repo.Migrations.AddForeignKeysToMessages do
  use Ecto.Migration

  def change do
    # First, check if we need to add the foreign keys
    # We'll execute a raw SQL query to check if the constraints exist
    constraint_exists = "SELECT 1 FROM pg_constraint WHERE conname = 'messages_sender_id_fkey'"
    
    # Only modify the table if the constraint doesn't exist
    execute "DO $$
    BEGIN
      IF NOT EXISTS (#{constraint_exists}) THEN
        ALTER TABLE messages 
        DROP CONSTRAINT IF EXISTS messages_sender_id_fkey,
        ADD CONSTRAINT messages_sender_id_fkey 
        FOREIGN KEY (sender_id) 
        REFERENCES users(id) ON DELETE NO ACTION;
        
        ALTER TABLE messages 
        DROP CONSTRAINT IF EXISTS messages_recipient_id_fkey,
        ADD CONSTRAINT messages_recipient_id_fkey 
        FOREIGN KEY (recipient_id) 
        REFERENCES users(id) ON DELETE NO ACTION;
      END IF;
    END
    $$;"
  end
end

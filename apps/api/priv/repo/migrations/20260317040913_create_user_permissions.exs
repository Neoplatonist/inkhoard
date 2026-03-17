defmodule InkHoard.Repo.Migrations.CreateUserPermissions do
  use Ecto.Migration

  def change do
    create table(:user_permissions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :tenant_id, :integer, null: false, default: 1
      add :role, :string, null: false, default: "user", size: 20
      add :admin, :boolean, null: false, default: false
      add :upload, :boolean, null: false, default: false
      add :download, :boolean, null: false, default: false
      add :edit_metadata, :boolean, null: false, default: false
      add :manage_library, :boolean, null: false, default: false
      add :email_book, :boolean, null: false, default: false
      add :delete_book, :boolean, null: false, default: false
      add :access_opds, :boolean, null: false, default: false
      add :sync_koreader, :boolean, null: false, default: false
      add :sync_kobo, :boolean, null: false, default: false
      add :manage_metadata_config, :boolean, null: false, default: false
      add :access_bookdrop, :boolean, null: false, default: false
      add :access_library_stats, :boolean, null: false, default: false
      add :access_user_stats, :boolean, null: false, default: false
      add :access_task_manager, :boolean, null: false, default: false
      add :manage_global_preferences, :boolean, null: false, default: false
      add :manage_icons, :boolean, null: false, default: false
      add :manage_fonts, :boolean, null: false, default: false
      add :bulk_auto_fetch_metadata, :boolean, null: false, default: false
      add :bulk_custom_fetch_metadata, :boolean, null: false, default: false
      add :bulk_edit_metadata, :boolean, null: false, default: false
      add :bulk_regenerate_cover, :boolean, null: false, default: false
      add :move_organize_files, :boolean, null: false, default: false
      add :bulk_lock_unlock_metadata, :boolean, null: false, default: false
      add :bulk_reset_inkhoard_progress, :boolean, null: false, default: false
      add :bulk_reset_koreader_progress, :boolean, null: false, default: false
      add :bulk_reset_read_status, :boolean, null: false, default: false
      add :demo_user, :boolean, null: false, default: false
      add :can_email_books, :boolean, null: false, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:user_permissions, [:user_id])
  end
end

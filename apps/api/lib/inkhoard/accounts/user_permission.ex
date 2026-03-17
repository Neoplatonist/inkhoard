defmodule InkHoard.Accounts.UserPermission do
  @moduledoc """
  UserPermission schema for managing user roles and permissions.

  Fields:
  - `user_id`: UUID foreign key to the users table.
  - `role`: String representing the user's role (e.g., "user", "admin").
  - `can_email_books`: Boolean indicating if the user can email books.

  Associations:
  - belongs_to :user, InkHoard.Accounts.User
  """

  use InkHoard.Schema

  schema "user_permissions" do
    field :role, :string, default: "user"
    field :tenant_id, :integer, default: 1
    field :admin, :boolean, default: false
    field :upload, :boolean, default: false
    field :download, :boolean, default: false
    field :edit_metadata, :boolean, default: false
    field :manage_library, :boolean, default: false
    field :email_book, :boolean, default: false
    field :delete_book, :boolean, default: false
    field :access_opds, :boolean, default: false
    field :sync_koreader, :boolean, default: false
    field :sync_kobo, :boolean, default: false
    field :manage_metadata_config, :boolean, default: false
    field :access_bookdrop, :boolean, default: false
    field :access_library_stats, :boolean, default: false
    field :access_user_stats, :boolean, default: false
    field :access_task_manager, :boolean, default: false
    field :manage_global_preferences, :boolean, default: false
    field :manage_icons, :boolean, default: false
    field :manage_fonts, :boolean, default: false
    field :bulk_auto_fetch_metadata, :boolean, default: false
    field :bulk_custom_fetch_metadata, :boolean, default: false
    field :bulk_edit_metadata, :boolean, default: false
    field :bulk_regenerate_cover, :boolean, default: false
    field :move_organize_files, :boolean, default: false
    field :bulk_lock_unlock_metadata, :boolean, default: false
    field :bulk_reset_inkhoard_progress, :boolean, default: false
    field :bulk_reset_koreader_progress, :boolean, default: false
    field :bulk_reset_read_status, :boolean, default: false
    field :demo_user, :boolean, default: false
    field :can_email_books, :boolean, default: true

    belongs_to :user, InkHoard.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end
end

defmodule InkHoard.Repo.Migrations.CreateLibraryUsers do
  use Ecto.Migration

  def change do
    create table(:library_users, primary_key: false) do
      add :library_id, references(:libraries, type: :uuid, on_delete: :delete_all),
        null: false,
        primary_key: true

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all),
        null: false,
        primary_key: true

      add :tenant_id, :integer, null: false, default: 1
    end

    create index(:library_users, [:user_id])
  end
end

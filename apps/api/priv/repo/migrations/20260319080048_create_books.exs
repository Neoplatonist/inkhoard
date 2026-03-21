defmodule InkHoard.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :library_id, references(:libraries, type: :uuid, on_delete: :delete_all), null: false
      add :library_path_id, references(:library_paths, type: :uuid, on_delete: :delete_all)
      add :tenant_id, :integer, null: false, default: 1
      add :is_physical, :boolean, null: false, default: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:books, [:tenant_id, :library_id])
    create index(:books, [:library_path_id])
    create index(:books, [:tenant_id, :deleted_at], where: "deleted_at IS NULL")
  end
end

defmodule InkHoard.Repo.Migrations.CreateLibraryPaths do
  use Ecto.Migration

  def change do
    create table(:library_paths, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :library_id, references(:libraries, type: :uuid, on_delete: :delete_all), null: false
      add :tenant_id, :integer, null: false, default: 1
      # path is absolute filesystem path
      add :path, :string, null: false, size: 1000

      timestamps(type: :utc_datetime_usec)
    end

    create index(:library_paths, [:library_id])
    create unique_index(:library_paths, [:tenant_id, :path])
  end
end

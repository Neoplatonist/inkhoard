defmodule InkHoard.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table(:libraries, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :tenant_id, :integer, null: false, default: 1
      add :name, :string, null: false, size: 255
      add :icon, :string, size: 255
      add :icon_type, :string, size: 50
      add :watch, :boolean, null: false, default: false
      add :format_priority, :map, default: fragment("'[\"epub\",\"pdf\",\"mobi\"]'")
      add :allowed_formats, :map
      add :metadata_source, :string, size: 50
      add :organization_mode, :string, size: 50
      add :file_naming_pattern, :string, size: 500

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:libraries, [:tenant_id, :name])
  end
end

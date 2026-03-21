defmodule InkHoard.Repo.Migrations.CreateBookFiles do
  use Ecto.Migration

  def change do
    create table(:book_files, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :book_id, references(:books, type: :uuid, on_delete: :delete_all), null: false
      add :tenant_id, :integer, null: false, default: 1
      add :format, :string, null: false, size: 20
      add :file_path, :string, null: false, size: 1000
      add :filename, :string, null: false, size: 500
      add :file_size, :bigint, null: false
      add :initial_hash, :string, null: false, size: 64
      add :current_hash, :string, null: false, size: 64
      add :mime_type, :string, size: 100

      timestamps(type: :utc_datetime_usec)
    end

    create index(:book_files, [:book_id])
    create index(:book_files, [:tenant_id, :initial_hash])
    create index(:book_files, [:tenant_id, :current_hash])
  end
end

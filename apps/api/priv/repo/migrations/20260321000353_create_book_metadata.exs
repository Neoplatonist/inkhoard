defmodule InkHoard.Repo.Migrations.CreateBookMetadata do
  use Ecto.Migration

  def change do
    create table(:book_metadata, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :book_id, references(:books, type: :uuid, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:book_metadata, [:book_id])
  end
end

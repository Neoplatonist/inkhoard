defmodule InkHoard.Repo.Migrations.CreateUserSettings do
  use Ecto.Migration

  def change do
    create table(:user_settings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :tenant_id, :integer, null: false, default: 1
      add :key, :string, null: false, size: 100
      # <- this is jsonb
      add :value, :map, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:user_settings, [:user_id, :key])
  end
end

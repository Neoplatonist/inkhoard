defmodule InkHoard.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :tenant_id, :integer, null: false, default: 1
      add :username, :string, null: false, size: 100
      add :email, :string, null: false, size: 255
      add :name, :string, size: 255
      add :password_hash, :string, size: 255
      add :avatar_url, :string, size: 500
      add :provisioning_method, :string, null: false, default: "local", size: 20
      add :is_default_password, :boolean, null: false, default: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:tenant_id, :username])
    create unique_index(:users, [:tenant_id, :email])
  end
end

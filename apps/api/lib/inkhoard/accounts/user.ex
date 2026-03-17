defmodule InkHoard.Accounts.User do
  @moduledoc """
  Schema and changeset for InkHoard user accounts.

  Supports local accounts (password-based) and OIDC/remote accounts
  (no password). The `:password` field is virtual — it is hashed via
  Bcrypt into `:password_hash` before persistence and never stored in
  plain text.

  ## Provisioning methods

    * `"local"` — standard username/password account
    * `"oidc"`  — identity provided by an external OIDC provider
    * `"remote"` — managed remotely (e.g. LDAP)
  """

  use InkHoard.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :avatar_url, :string
    field :provisioning_method, :string, default: "local"
    field :is_default_password, :boolean, default: false
    field :tenant_id, :integer, default: 1
    field :deleted_at, :utc_datetime_usec

    has_one :user_permission, InkHoard.Accounts.UserPermission
    has_one :user_settings, InkHoard.Accounts.UserSettings

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :name])
    |> put_password_hash()
    |> validate_required([:username, :email, :password_hash])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_format(:username, ~r/^\w+$/)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:username, name: :users_tenant_id_username_index)
    |> unique_constraint(:email, name: :users_tenant_id_email_index)
    |> validate_length(:password, min: 8)
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end

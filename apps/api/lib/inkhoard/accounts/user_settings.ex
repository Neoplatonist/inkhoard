defmodule InkHoard.Accounts.UserSettings do
  @moduledoc """
  Schema for per-user key-value preferences.

  Each row is one setting (e.g. `key: "theme"`, `value: %{"mode" => "dark"}`).
  The `value` field is a JSONB column, represented in Elixir as a map.

  ## Fields

    * `key`       - setting name, e.g. `"theme"`, `"language"`, `"dashboard_config"`
    * `value`     - structured value stored as JSONB
    * `tenant_id` - SaaS tenant scoping, default `1`

  ## Associations

    * `belongs_to :user, InkHoard.Accounts.User`
  """

  use InkHoard.Schema
  import Ecto.Changeset

  schema "user_settings" do
    field :tenant_id, :integer, default: 1
    field :key, :string
    field :value, :map

    belongs_to :user, InkHoard.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user_settings, attrs) do
    user_settings
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end

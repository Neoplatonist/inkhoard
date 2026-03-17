defmodule InkHoard.Schema do
  @moduledoc """
  Shared schema configuration for all InkHoard Ecto schemas.

  Sets UUID v7 primary keys, UUID foreign key type, and microsecond UTC timestamps.

  ## Usage

      defmodule InkHoard.Accounts.User do
        use InkHoard.Schema

        schema "users" do
          field :username, :string
          timestamps()
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      @primary_key {:id, Ecto.UUID, autogenerate: {InkHoard.UUID, :generate, []}}
      @foreign_key_type Ecto.UUID
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end

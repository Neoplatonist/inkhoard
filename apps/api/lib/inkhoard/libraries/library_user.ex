defmodule InkHoard.Libraries.LibraryUser do
  use InkHoard.Schema
  import Ecto.Changeset

  @primary_key false

  schema "library_users" do
    field :tenant_id, :integer, default: 1

    belongs_to :library, InkHoard.Libraries.Library, primary_key: true
    belongs_to :user, InkHoard.Accounts.User, primary_key: true
  end

  def changeset(library_user, attrs) do
    library_user
    |> cast(attrs, [:library_id, :user_id])
    |> validate_required([:library_id, :user_id])
    |> assoc_constraint(:library)
    |> assoc_constraint(:user)
    |> unique_constraint(:library_id, name: :library_users_pkey)
  end
end

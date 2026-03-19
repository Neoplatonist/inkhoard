defmodule InkHoard.Libraries.LibraryPath do
  @moduledoc """
  Schema for a filesystem path belonging to a library.

  Paths must be absolute (enforced by changeset validation and DB constraint).
  Two changesets are provided:

    * `changeset/2` — full validation including `library_id`, used for direct inserts
    * `path_only_changeset/2` — path fields only, used when building paths through
      the parent `Library` association via `put_assoc` (Ecto assigns the FK automatically)
  """

  use InkHoard.Schema
  import Ecto.Changeset

  schema "library_paths" do
    field :tenant_id, :integer, default: 1
    field :path, :string

    belongs_to :library, InkHoard.Libraries.Library

    timestamps()
  end

  def changeset(library_path, attrs) do
    library_path
    |> cast(attrs, [:library_id, :path])
    |> validate_required([:library_id, :path])
    |> validate_length(:path, min: 1, max: 1000)
    |> validate_format(:path, ~r|^/|, message: "must be an absolute path")
    |> assoc_constraint(:library)
    |> unique_constraint(:path, name: :library_paths_tenant_id_path_index)
  end

  # Used when building paths through the parent Library association.
  # The library_id FK is assigned automatically by Ecto via put_assoc.
  def path_only_changeset(library_path, attrs) do
    library_path
    |> cast(attrs, [:path])
    |> validate_required([:path])
    |> validate_length(:path, min: 1, max: 1000)
    |> validate_format(:path, ~r|^/|, message: "must be an absolute path")
    |> unique_constraint(:path, name: :library_paths_tenant_id_path_index)
  end
end

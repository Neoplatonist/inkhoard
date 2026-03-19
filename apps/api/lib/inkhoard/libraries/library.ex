defmodule InkHoard.Libraries.Library do
  @moduledoc """
  Schema for a library — a named collection of books backed by filesystem paths.

  Libraries are tenant-scoped and require at least one `LibraryPath` on
  creation (enforced by `create_changeset/2`). Use `changeset/2` for
  updates to the library's own fields without touching paths.
  """

  use InkHoard.Schema
  import Ecto.Changeset

  alias InkHoard.Libraries.LibraryPath

  schema "libraries" do
    field :tenant_id, :integer, default: 1
    field :name, :string
    field :icon, :string
    field :icon_type, :string
    field :watch, :boolean, default: false
    field :format_priority, {:array, :string}
    field :allowed_formats, {:array, :string}
    field :metadata_source, :string
    field :organization_mode, :string
    field :file_naming_pattern, :string

    has_many :library_paths, InkHoard.Libraries.LibraryPath
    has_many :library_users, InkHoard.Libraries.LibraryUser

    timestamps()
  end

  def changeset(library, attrs) do
    library
    |> cast(attrs, [
      :name,
      :icon,
      :icon_type,
      :watch,
      :format_priority,
      :allowed_formats,
      :metadata_source,
      :organization_mode,
      :file_naming_pattern
    ])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:icon, max: 255)
    |> validate_length(:icon_type, max: 50)
    |> validate_length(:metadata_source, max: 50)
    |> validate_length(:organization_mode, max: 50)
    |> validate_length(:file_naming_pattern, max: 500)
    |> unique_constraint(:name, name: :libraries_tenant_id_name_index)
  end

  # Used by Libraries.create_library/1. Handles the paths list atomically
  # alongside the library insert — no Multi needed.
  def create_changeset(library, attrs) do
    {paths, library_attrs} = Map.pop(attrs, :paths, [])

    path_changesets =
      Enum.map(paths, &LibraryPath.path_only_changeset(%LibraryPath{}, %{path: &1}))

    library
    |> changeset(library_attrs)
    |> put_assoc(:library_paths, path_changesets)
    |> validate_paths_present(paths)
  end

  defp validate_paths_present(changeset, []),
    do: add_error(changeset, :paths, "must have at least one path")

  defp validate_paths_present(changeset, _paths), do: changeset
end

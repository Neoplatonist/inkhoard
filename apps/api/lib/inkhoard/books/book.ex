defmodule InkHoard.Books.Book do
  @moduledoc """
  Schema for a book in a library.

  A book belongs to a `Library` and optionally to a `LibraryPath` (physical
  books have no path). Soft deletion is handled via `deleted_at` rather than
  hard deletes to preserve associated reading progress and annotations.
  """

  use InkHoard.Schema
  import Ecto.Changeset

  alias InkHoard.Books.BookFile
  alias InkHoard.Libraries.Library
  alias InkHoard.Libraries.LibraryPath

  schema "books" do
    field :tenant_id, :integer, default: 1
    field :is_physical, :boolean, default: false
    field :deleted_at, :utc_datetime_usec

    belongs_to :library, Library
    belongs_to :library_path, LibraryPath
    has_many :book_files, BookFile
    has_one :metadata, InkHoard.Books.Metadata

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for creating or updating a book.

  Required: `:library_id`. Optional: `:library_path_id`, `:is_physical`, `:deleted_at`.
  """
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:library_id, :library_path_id, :is_physical, :deleted_at])
    |> validate_required([:library_id])
    |> assoc_constraint(:library)
    |> assoc_constraint(:library_path)
  end
end

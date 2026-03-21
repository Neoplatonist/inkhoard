defmodule InkHoard.Books.BookFile do
  @moduledoc """
  Schema for a physical file associated with a book.

  A book may have multiple files (e.g. both an EPUB and a PDF). Hashes are
  partial MD5s: `initial_hash` is immutable and set on first import;
  `current_hash` is updated on writes and used to detect file changes.
  """

  use InkHoard.Schema
  import Ecto.Changeset

  @valid_formats ~w(epub pdf cbz cbr cb7 mobi azw3 fb2 mp3 m4a m4b flac ogg)

  schema "book_files" do
    field :tenant_id, :integer, default: 1
    field :format, :string
    field :file_path, :string
    field :filename, :string
    field :file_size, :integer
    field :initial_hash, :string
    field :current_hash, :string
    field :mime_type, :string

    belongs_to :book, InkHoard.Books.Book

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for creating or updating a book file.

  Required: `:book_id`, `:format`, `:file_path`, `:filename`, `:file_size`,
  `:initial_hash`, `:current_hash`.

  `:format` must be one of: `#{Enum.join(@valid_formats, " ")}`.

  `:file_size` must be >= 0.

  `:initial_hash` is set on first import and should not change. `:current_hash`
  is updated on each write and is used to detect file modifications.
  """
  def changeset(book_file, attrs) do
    book_file
    |> cast(attrs, [
      :book_id,
      :format,
      :file_path,
      :filename,
      :file_size,
      :initial_hash,
      :current_hash,
      :mime_type
    ])
    |> validate_required([
      :book_id,
      :format,
      :file_path,
      :filename,
      :file_size,
      :initial_hash,
      :current_hash
    ])
    |> validate_inclusion(:format, @valid_formats)
    |> validate_number(:file_size, greater_than_or_equal_to: 0)
    |> assoc_constraint(:book)
  end
end

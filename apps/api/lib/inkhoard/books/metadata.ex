defmodule InkHoard.Books.Metadata do
  @moduledoc """
  Stub schema for book metadata. Full implementation in Story 1.5.
  """

  use InkHoard.Schema

  schema "book_metadata" do
    belongs_to :book, InkHoard.Books.Book

    timestamps(type: :utc_datetime_usec)
  end
end

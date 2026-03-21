defmodule InkHoard.Books do
  @moduledoc """
  Context for managing books and their associated files.

  Books are the core entity in InkHoard. Each book belongs to a `Library` and
  optionally to a `LibraryPath`. Physical books (e.g. a book you own but haven't
  scanned) can exist without a path.

  Soft deletion is used throughout: `delete_book/1` hard-deletes via the DB
  cascade, but the `deleted_at` field is available for callers that want to
  implement soft-delete semantics at a higher layer.
  """

  import Ecto.Query

  alias InkHoard.Books.Book
  alias InkHoard.Repo

  @doc """
  Creates a book from the given attributes.

  ## Required attributes

    * `:library_id` — the library this book belongs to

  ## Optional attributes

    * `:library_path_id` — the scanned path the file was found under
    * `:is_physical` — defaults to `false`

  ## Examples

      iex> create_book(%{library_id: "some-uuid"})
      {:ok, %Book{}}

      iex> create_book(%{})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetches a single book by ID, preloading its `book_files`.

  Soft-deleted books (where `deleted_at` is set) are treated as non-existent.

  ## Examples

      iex> get_book("existing-uuid")
      {:ok, %Book{book_files: [...]}}

      iex> get_book("missing-uuid")
      {:error, :not_found}

  """
  def get_book(id) do
    query =
      from b in Book,
        where: b.id == ^id and is_nil(b.deleted_at),
        preload: [:book_files]

    case Repo.one(query) do
      nil -> {:error, :not_found}
      book -> {:ok, book}
    end
  end

  @doc """
  Returns a paginated list of non-deleted books.

  ## Options

    * `:page` — 1-based page number, defaults to `1`
    * `:page_size` — number of results per page, defaults to `25`, capped at `100`

  ## Return value

  Always returns `{:ok, result}` where `result` is:

      %{
        data: [%Book{}, ...],
        pagination: %{
          page: integer(),
          page_size: integer(),
          total_count: integer(),
          total_pages: integer()
        }
      }

  ## Examples

      iex> list_books(%{page: 2, page_size: 10})
      {:ok, %{data: [...], pagination: %{page: 2, page_size: 10, ...}}}

      iex> list_books(%{})
      {:ok, %{data: [...], pagination: %{page: 1, page_size: 25, ...}}}

  """
  def list_books(params \\ %{}) do
    page = Map.get(params, :page, 1)
    page_size = params |> Map.get(:page_size, 25) |> min(100)
    offset = (page - 1) * page_size

    base = from b in Book, where: is_nil(b.deleted_at)

    total_count = Repo.aggregate(base, :count, :id)
    total_pages = ceil(total_count / page_size)

    data =
      base
      |> limit(^page_size)
      |> offset(^offset)
      |> Repo.all()

    {:ok,
     %{
       data: data,
       pagination: %{
         page: page,
         page_size: page_size,
         total_count: total_count,
         total_pages: total_pages
       }
     }}
  end

  @doc """
  Deletes a book by struct or ID. Associated `book_files` are removed by the
  database cascade on the `book_id` foreign key.

  Accepts either a `%Book{}` struct (no extra query needed) or a UUID string
  (fetches first, then deletes).

  ## Examples

      iex> delete_book(%Book{})
      {:ok, %Book{}}

      iex> delete_book("existing-uuid")
      {:ok, %Book{}}

      iex> delete_book("missing-uuid")
      {:error, :not_found}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  def delete_book(id) do
    case Repo.get(Book, id) do
      nil -> {:error, :not_found}
      book -> Repo.delete(book)
    end
  end
end

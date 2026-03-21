defmodule InkHoard.BooksTest do
  use InkHoard.DataCase, async: false

  import InkHoard.Factory

  alias InkHoard.Books
  alias InkHoard.Books.BookFile
  alias InkHoard.Repo

  describe "create_book/1" do
    test "with valid attrs creates book linked to library_path" do
      library_path = insert(:library_path)

      attrs = %{library_id: library_path.library_id, library_path_id: library_path.id}

      assert {:ok, book} = Books.create_book(attrs)
      assert book.library_id == library_path.library_id
      assert book.library_path_id == library_path.id
      assert book.is_physical == false
      assert book.tenant_id == 1
    end

    test "without library_id returns {:error, changeset} with :library_id error" do
      assert {:error, changeset} = Books.create_book(%{})
      assert errors_on(changeset).library_id
    end

    test "physical book can be created without a library_path_id" do
      library = insert(:library)

      assert {:ok, book} = Books.create_book(%{library_id: library.id, is_physical: true})
      assert book.is_physical == true
      assert is_nil(book.library_path_id)
    end
  end

  describe "get_book/1" do
    test "with valid ID returns {:ok, book} with preloaded book_files" do
      book = insert(:book)
      insert(:book_file, book: book)

      assert {:ok, found} = Books.get_book(book.id)
      assert found.id == book.id
      assert is_list(found.book_files)
      assert length(found.book_files) == 1
    end

    test "with valid ID returns {:ok, book} with empty book_files when none exist" do
      book = insert(:book)

      assert {:ok, found} = Books.get_book(book.id)
      assert found.book_files == []
    end

    test "with invalid ID returns {:error, :not_found}" do
      assert {:error, :not_found} = Books.get_book(Ecto.UUID.generate())
    end

    test "does not return soft-deleted books" do
      book = insert(:book, deleted_at: DateTime.utc_now())

      assert {:error, :not_found} = Books.get_book(book.id)
    end
  end

  describe "list_books/1" do
    test "returns paginated envelope with data and pagination keys" do
      insert_list(3, :book)

      assert {:ok, result} = Books.list_books(%{page: 1, page_size: 2})
      assert is_list(result.data)
      assert length(result.data) == 2
      assert result.pagination.page == 1
      assert result.pagination.page_size == 2
      assert result.pagination.total_count >= 3
      assert result.pagination.total_pages >= 2
    end

    test "defaults to page 1, page_size 25 when no params given" do
      assert {:ok, result} = Books.list_books(%{})
      assert result.pagination.page == 1
      assert result.pagination.page_size == 25
    end

    test "clamps page_size to 100 maximum" do
      assert {:ok, result} = Books.list_books(%{page_size: 999})
      assert result.pagination.page_size == 100
    end

    test "excludes soft-deleted books" do
      active = insert(:book)
      _deleted = insert(:book, deleted_at: DateTime.utc_now())

      assert {:ok, result} = Books.list_books(%{})
      ids = Enum.map(result.data, & &1.id)

      assert active.id in ids
      refute _deleted.id in ids
    end
  end

  describe "delete_book/1" do
    test "removes book and cascades to book_files" do
      book = insert(:book)
      file = insert(:book_file, book: book)

      assert {:ok, _} = Books.delete_book(book)
      assert Repo.get(InkHoard.Books.Book, book.id) == nil
      assert Repo.get(BookFile, file.id) == nil
    end
  end
end

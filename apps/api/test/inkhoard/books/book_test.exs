defmodule InkHoard.Books.BookTest do
  use InkHoard.DataCase, async: true

  import InkHoard.Factory

  alias InkHoard.Books.Book
  alias InkHoard.Books.BookFile
  alias InkHoard.Repo

  describe "Book associations" do
    test "belongs_to Library and LibraryPath" do
      book = insert(:book)

      loaded = Repo.preload(book, [:library, :library_path])

      assert loaded.library.id == book.library_id
      assert loaded.library_path.id == book.library_path_id
    end

    test "has_many BookFile" do
      book = insert(:book)
      insert(:book_file, book: book)
      insert(:book_file, book: book)

      loaded = Repo.preload(book, :book_files)

      assert length(loaded.book_files) == 2
      assert Enum.all?(loaded.book_files, &(&1.book_id == book.id))
    end

    test "has_one Metadata (nil when none created)" do
      book = insert(:book)

      loaded = Repo.preload(book, :metadata)

      assert is_nil(loaded.metadata)
    end
  end

  describe "Book changeset/2" do
    test "requires library_id" do
      changeset = Book.changeset(%Book{}, %{})

      assert errors_on(changeset).library_id
    end

    test "with valid attrs produces a valid changeset" do
      library_path = insert(:library_path)

      changeset =
        Book.changeset(%Book{}, %{
          library_id: library_path.library_id,
          library_path_id: library_path.id
        })

      assert changeset.valid?
    end
  end

  describe "BookFile changeset/2" do
    test "requires file_path" do
      book = insert(:book)

      changeset =
        BookFile.changeset(%BookFile{}, %{
          book_id: book.id,
          format: "epub",
          filename: "book.epub",
          file_size: 1024,
          initial_hash: "abc123def456",
          current_hash: "abc123def456"
        })

      assert errors_on(changeset).file_path
    end

    test "requires filename" do
      book = insert(:book)

      changeset =
        BookFile.changeset(%BookFile{}, %{
          book_id: book.id,
          format: "epub",
          file_path: "books/book.epub",
          file_size: 1024,
          initial_hash: "abc123def456",
          current_hash: "abc123def456"
        })

      assert errors_on(changeset).filename
    end

    test "rejects file_size below zero" do
      book = insert(:book)

      changeset =
        BookFile.changeset(%BookFile{}, %{
          book_id: book.id,
          format: "epub",
          file_path: "books/book.epub",
          filename: "book.epub",
          file_size: -1,
          initial_hash: "abc123def456",
          current_hash: "abc123def456"
        })

      assert errors_on(changeset).file_size
    end

    test "rejects invalid format" do
      changeset = BookFile.changeset(%BookFile{}, %{format: "docx"})

      assert errors_on(changeset).format
    end

    test "accepts all valid formats" do
      valid_formats = ~w(epub pdf cbz cbr cb7 mobi azw3 fb2 mp3 m4a m4b flac ogg)

      for format <- valid_formats do
        changeset = BookFile.changeset(%BookFile{}, %{format: format})
        refute :format in Keyword.keys(changeset.errors), "expected #{format} to be valid"
      end
    end
  end
end

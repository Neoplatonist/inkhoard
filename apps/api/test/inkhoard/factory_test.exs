defmodule InkHoard.FactoryTest do
  use InkHoard.DataCase, async: true

  import InkHoard.Factory

  describe "user_factory" do
    test "inserts a persisted user with unique username and email" do
      user = insert(:user)

      assert user.id != nil
      assert user.username != nil
      assert user.email != nil
      assert user.password_hash != nil
    end

    test "each call produces a unique user" do
      user1 = insert(:user)
      user2 = insert(:user)

      assert user1.username != user2.username
      assert user1.email != user2.email
    end
  end

  describe "library_factory" do
    test "inserts a persisted library" do
      library = insert(:library)

      assert library.id != nil
      assert library.name != nil
      assert library.tenant_id == 1
    end

    test "each call produces a library with a unique name" do
      lib1 = insert(:library)
      lib2 = insert(:library)

      assert lib1.name != lib2.name
    end
  end

  describe "library_path_factory" do
    test "inserts a persisted library_path with an absolute path linked to a library" do
      library_path = insert(:library_path)

      assert library_path.id != nil
      assert library_path.library_id != nil
      assert String.starts_with?(library_path.path, "/")
    end

    test "can be associated to an explicit library" do
      library = insert(:library)
      library_path = insert(:library_path, library: library)

      assert library_path.library_id == library.id
    end
  end

  describe "book_factory" do
    test "inserts a persisted book linked to a library and library_path" do
      book = insert(:book)

      assert book.id != nil
      assert book.library_id != nil
      assert book.library_path_id != nil
      assert book.tenant_id == 1
      assert book.is_physical == false
    end

    test "can be associated to an explicit library_path" do
      library_path = insert(:library_path)
      book = insert(:book, library_path: library_path)

      assert book.library_path_id == library_path.id
      assert book.library_id == library_path.library_id
    end
  end

  describe "book_file_factory" do
    test "inserts a persisted book_file linked to a book" do
      book_file = insert(:book_file)

      assert book_file.id != nil
      assert book_file.book_id != nil
      assert book_file.format != nil
      assert book_file.file_path != nil
      assert book_file.filename != nil
      assert book_file.file_size > 0
      assert book_file.initial_hash != nil
      assert book_file.current_hash != nil
    end

    test "can be associated to an explicit book" do
      book = insert(:book)
      book_file = insert(:book_file, book: book)

      assert book_file.book_id == book.id
    end

    test "each call produces a unique file_path" do
      bf1 = insert(:book_file)
      bf2 = insert(:book_file)

      assert bf1.file_path != bf2.file_path
    end
  end

  describe "insert_list/2" do
    test "inserts multiple books" do
      books = insert_list(3, :book)

      assert length(books) == 3
      ids = Enum.map(books, & &1.id)
      assert length(Enum.uniq(ids)) == 3
    end
  end
end

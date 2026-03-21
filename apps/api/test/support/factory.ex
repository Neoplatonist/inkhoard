defmodule InkHoard.Factory do
  @moduledoc """
  ExMachina factory module for building and inserting test data.

  Import this module in test files to get access to `build/2`, `insert/2`,
  `insert_list/3`, and related helpers.

  ## Available factories

    * `:user` — `Accounts.User` with unique username and email
    * `:library` — `Libraries.Library` with a unique name
    * `:library_path` — `Libraries.LibraryPath` with an absolute path, linked to a library
    * `:book` — `Books.Book` linked to a library and library path
    * `:book_file` — `Books.BookFile` with all required file fields, linked to a book

  ## Usage

      import InkHoard.Factory

      book = insert(:book)
      file = insert(:book_file, book: book)
      users = insert_list(3, :user)

  """
  use ExMachina.Ecto, repo: InkHoard.Repo

  alias InkHoard.Accounts.User
  alias InkHoard.Books.Book
  alias InkHoard.Books.BookFile
  alias InkHoard.Libraries.Library
  alias InkHoard.Libraries.LibraryPath

  def user_factory do
    %User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"user#{&1}@example.com"),
      password_hash: Bcrypt.hash_pwd_salt("password123")
    }
  end

  def library_factory do
    %Library{
      name: sequence(:library_name, &"Library #{&1}")
    }
  end

  def library_path_factory do
    %LibraryPath{
      path: sequence(:library_path, &"/books/library#{&1}"),
      library: build(:library)
    }
  end

  def book_factory(attrs) do
    library_path = Map.get_lazy(attrs, :library_path, fn -> build(:library_path) end)

    base = %Book{library_path: library_path}

    base_with_library =
      case {Map.get(attrs, :library), library_path} do
        {lib, _} when not is_nil(lib) ->
          %{base | library: lib}

        {nil, %{__meta__: %{state: :loaded}, library_id: lib_id}} when not is_nil(lib_id) ->
          # library_path is already persisted — reuse its library_id directly to
          # avoid re-inserting a shared struct and to satisfy the constraint
          # book.library_id == library_path.library_id
          %{base | library_id: lib_id}

        _ ->
          %{base | library: build(:library)}
      end

    base_with_library
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def book_file_factory do
    %BookFile{
      format: "epub",
      file_path: sequence(:book_file_path, &"/books/library/book#{&1}.epub"),
      filename: sequence(:book_filename, &"book#{&1}.epub"),
      file_size: 1_048_576,
      initial_hash: sequence(:book_file_initial_hash, &"ihash#{&1}"),
      current_hash: sequence(:book_file_current_hash, &"chash#{&1}"),
      book: build(:book)
    }
  end
end

defmodule InkHoard.LibrariesTest do
  use InkHoard.DataCase, async: false

  alias InkHoard.Accounts
  alias InkHoard.Libraries
  alias InkHoard.Libraries.LibraryUser
  alias InkHoard.Repo

  describe "create_library/1" do
    test "with valid attrs creates library with paths" do
      attrs = valid_library_attrs()

      assert {:ok, library} = Libraries.create_library(attrs)
      assert library.__struct__ == InkHoard.Libraries.Library
      assert library.name == attrs.name

      loaded = Repo.preload(library, :library_paths)
      assert length(loaded.library_paths) == 1
      assert hd(loaded.library_paths).path == hd(attrs.paths)
    end

    test "with duplicate name returns {:error, changeset} with :name error" do
      attrs = valid_library_attrs()
      assert {:ok, _library} = Libraries.create_library(attrs)

      assert {:error, changeset} = Libraries.create_library(attrs)
      assert "has already been taken" in errors_on(changeset).name
    end

    test "with no paths returns {:error, changeset} with :paths error" do
      attrs = valid_library_attrs(%{paths: []})

      assert {:error, changeset} = Libraries.create_library(attrs)
      assert errors_on(changeset).paths
    end
  end

  describe "get_library/1" do
    test "with valid ID returns {:ok, library}" do
      {:ok, library} = Libraries.create_library(valid_library_attrs())

      assert {:ok, found} = Libraries.get_library(library.id)
      assert found.id == library.id
      assert found.name == library.name
    end

    test "with invalid ID returns {:error, :not_found}" do
      assert {:error, :not_found} = Libraries.get_library(Ecto.UUID.generate())
    end
  end

  describe "update_library/2" do
    test "with valid attrs updates name" do
      {:ok, library} = Libraries.create_library(valid_library_attrs())

      assert {:ok, updated} = Libraries.update_library(library, %{name: "Renamed"})
      assert updated.name == "Renamed"
    end

    test "with invalid attrs returns {:error, changeset}" do
      {:ok, library} = Libraries.create_library(valid_library_attrs())

      assert {:error, changeset} = Libraries.update_library(library, %{name: ""})
      assert errors_on(changeset).name
    end
  end

  describe "delete_library/1" do
    test "removes library and cascades to paths and user access" do
      {:ok, user} = Accounts.create_user(valid_user_attrs())
      {:ok, library} = Libraries.create_library(valid_library_attrs())
      Libraries.grant_access(library.id, user.id)

      loaded = Repo.preload(library, :library_paths)
      path_ids = Enum.map(loaded.library_paths, & &1.id)

      assert {:ok, _} = Libraries.delete_library(library)

      assert Repo.get(InkHoard.Libraries.Library, library.id) == nil

      Enum.each(path_ids, fn id ->
        assert Repo.get(InkHoard.Libraries.LibraryPath, id) == nil
      end)

      refute Repo.get_by(LibraryUser, library_id: library.id, user_id: user.id)
    end
  end

  describe "list_libraries_for_user/1" do
    test "returns only libraries the user has access to" do
      {:ok, user} = Accounts.create_user(valid_user_attrs())
      {:ok, accessible} = Libraries.create_library(valid_library_attrs())
      {:ok, inaccessible} = Libraries.create_library(valid_library_attrs())

      Libraries.grant_access(accessible.id, user.id)

      libraries = Libraries.list_libraries_for_user(user.id)
      ids = Enum.map(libraries, & &1.id)

      assert accessible.id in ids
      refute inaccessible.id in ids
    end

    test "admin users see all libraries regardless of access records" do
      {:ok, user} = Accounts.create_user(valid_user_attrs())

      Repo.delete_all(
        from(p in LibraryUser, where: p.user_id == ^user.id)
      )

      permission = Repo.get_by!(InkHoard.Accounts.UserPermission, user_id: user.id)
      Repo.update!(Ecto.Changeset.change(permission, admin: true))

      {:ok, lib1} = Libraries.create_library(valid_library_attrs())
      {:ok, lib2} = Libraries.create_library(valid_library_attrs())

      libraries = Libraries.list_libraries_for_user(user.id)
      ids = Enum.map(libraries, & &1.id)

      assert lib1.id in ids
      assert lib2.id in ids
    end
  end

  describe "grant_access/2" do
    test "creates a library_users record" do
      {:ok, user} = Accounts.create_user(valid_user_attrs())
      {:ok, library} = Libraries.create_library(valid_library_attrs())

      assert {:ok, access} = Libraries.grant_access(library.id, user.id)
      assert access.__struct__ == InkHoard.Libraries.LibraryUser
      assert access.library_id == library.id
      assert access.user_id == user.id
    end
  end

  describe "revoke_access/2" do
    test "removes the library_users record" do
      {:ok, user} = Accounts.create_user(valid_user_attrs())
      {:ok, library} = Libraries.create_library(valid_library_attrs())
      Libraries.grant_access(library.id, user.id)

      assert :ok = Libraries.revoke_access(library.id, user.id)

      refute Repo.get_by(InkHoard.Libraries.LibraryUser,
               library_id: library.id,
               user_id: user.id
             )
    end
  end

  describe "associations" do
    test "Library has_many LibraryPath and LibraryUser" do
      {:ok, library} = Libraries.create_library(valid_library_attrs())
      loaded = Repo.preload(library, [:library_paths, :library_users])

      assert is_list(loaded.library_paths)
      assert is_list(loaded.library_users)
    end

    test "LibraryUser enforces unique constraint on {library_id, user_id}" do
      {:ok, user} = Accounts.create_user(valid_user_attrs())
      {:ok, library} = Libraries.create_library(valid_library_attrs())

      assert {:ok, _} = Libraries.grant_access(library.id, user.id)
      assert {:error, changeset} = Libraries.grant_access(library.id, user.id)
      assert errors_on(changeset).library_id || errors_on(changeset).user_id
    end
  end

  defp valid_library_attrs(overrides \\ %{}) do
    uniq = System.unique_integer([:positive])

    Map.merge(
      %{
        name: "Library #{uniq}",
        paths: ["/books/#{uniq}"]
      },
      overrides
    )
  end

  defp valid_user_attrs(overrides \\ %{}) do
    uniq = System.unique_integer([:positive])

    Map.merge(
      %{
        username: "user_#{uniq}",
        email: "user_#{uniq}@example.com",
        password: "strongpass123"
      },
      overrides
    )
  end
end

defmodule InkHoard.Libraries do
  @moduledoc """
  Context for managing libraries, library paths, and user access.

  A library is a named container for books backed by one or more filesystem
  paths (`LibraryPath`). Access is controlled per-user via `LibraryUser`
  join records; admin users bypass access checks and see all libraries.

  ## Functions

    * CRUD — `create_library/1`, `get_library/1`, `update_library/2`, `delete_library/1`
    * Listing — `list_libraries_for_user/1`
    * Access control — `grant_access/2`, `revoke_access/2`

  > Adding and removing paths on an existing library (`add_library_path/2`,
  > `remove_library_path/2`) is deferred to Story 3.7.
  """

  import Ecto.Query

  alias InkHoard.Accounts.UserPermission
  alias InkHoard.Libraries.Library
  alias InkHoard.Libraries.LibraryUser
  alias InkHoard.Repo

  def create_library(attrs) do
    %Library{}
    |> Library.create_changeset(attrs)
    |> Repo.insert()
  end

  def get_library(id) do
    case Repo.get(Library, id) do
      nil -> {:error, :not_found}
      library -> {:ok, library}
    end
  end

  def update_library(%Library{} = library, attrs) do
    library
    |> Library.changeset(attrs)
    |> Repo.update()
  end

  def delete_library(%Library{} = library) do
    Repo.delete(library)
  end

  def list_libraries_for_user(user_id) do
    if admin?(user_id) do
      Repo.all(Library)
    else
      Repo.all(
        from l in Library,
          join: lu in LibraryUser,
          on: lu.library_id == l.id,
          where: lu.user_id == ^user_id
      )
    end
  end

  def grant_access(library_id, user_id) do
    %LibraryUser{}
    |> LibraryUser.changeset(%{library_id: library_id, user_id: user_id})
    |> Repo.insert()
  end

  def revoke_access(library_id, user_id) do
    case Repo.get_by(LibraryUser, library_id: library_id, user_id: user_id) do
      nil -> :ok
      record -> Repo.delete!(record) && :ok
    end
  end

  defp admin?(user_id) do
    case Repo.get_by(UserPermission, user_id: user_id) do
      %UserPermission{admin: true} -> true
      _ -> false
    end
  end
end

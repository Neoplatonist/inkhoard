defmodule InkHoard.Accounts do
  @moduledoc """
  Context for managing user accounts.

  Handles user creation (with automatic permission and settings rows)
  and user lookup.
  """

  alias Ecto.Multi
  alias InkHoard.Accounts.User
  alias InkHoard.Accounts.UserPermission
  alias InkHoard.Accounts.UserSettings
  alias InkHoard.Repo

  def create_user(attrs) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Multi.insert(
      :user_permission,
      fn %{user: user} ->
        %UserPermission{user_id: user.id}
      end
    )
    |> Multi.insert(
      :user_settings,
      fn %{user: user} ->
        %UserSettings{user_id: user.id, key: "default", value: %{}}
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
      {:error, :user_permission, changeset, _} -> {:error, changeset}
      {:error, :user_settings, changeset, _} -> {:error, changeset}
    end
  end

  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end

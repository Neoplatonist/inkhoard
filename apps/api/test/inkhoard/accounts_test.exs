defmodule InkHoard.AccountsTest do
  use InkHoard.DataCase, async: false

  alias InkHoard.Accounts
  alias InkHoard.Repo

  describe "create_user/1" do
    test "with valid attrs creates user with hashed password (not plaintext)" do
      attrs = valid_user_attrs()

      assert {:ok, user} = Accounts.create_user(attrs)
      assert user.__struct__ == InkHoard.Accounts.User
      assert user.username == attrs.username
      assert user.email == attrs.email
      refute user.password_hash == attrs.password
      assert is_binary(user.password_hash)
      assert user.password_hash != ""
    end

    test "with duplicate username returns {:error, changeset} with :username error" do
      attrs = valid_user_attrs()
      assert {:ok, _user} = Accounts.create_user(attrs)

      dup_attrs = valid_user_attrs(%{username: attrs.username})

      assert {:error, changeset} = Accounts.create_user(dup_attrs)
      assert "has already been taken" in errors_on(changeset).username
    end

    test "with duplicate email returns {:error, changeset} with :email error" do
      attrs = valid_user_attrs()
      assert {:ok, _user} = Accounts.create_user(attrs)

      dup_attrs = valid_user_attrs(%{email: attrs.email})

      assert {:error, changeset} = Accounts.create_user(dup_attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "with weak password (< 8 chars) returns validation error" do
      attrs = valid_user_attrs(%{password: "short"})

      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end
  end

  describe "get_user/1" do
    test "with valid ID returns {:ok, user}" do
      attrs = valid_user_attrs()
      assert {:ok, created} = Accounts.create_user(attrs)

      assert {:ok, fetched} = Accounts.get_user(created.id)
      assert fetched.__struct__ == InkHoard.Accounts.User
      assert fetched.id == created.id
    end

    test "with invalid ID returns {:error, :not_found}" do
      assert {:error, :not_found} = Accounts.get_user(Ecto.UUID.generate())
    end

    test "user has_one UserPermission and has_one UserSettings with expected defaults" do
      attrs = valid_user_attrs()
      assert {:ok, created} = Accounts.create_user(attrs)
      assert {:ok, fetched} = Accounts.get_user(created.id)

      loaded = Repo.preload(fetched, [:user_permission, :user_settings])

      assert loaded.user_permission
      assert loaded.user_settings
      assert loaded.user_permission.role == "user"
      assert loaded.user_permission.can_email_books == true
    end
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

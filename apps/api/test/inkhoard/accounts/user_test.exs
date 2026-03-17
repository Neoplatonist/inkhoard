defmodule InkHoard.Accounts.UserTest do
  use InkHoard.DataCase, async: true

  alias InkHoard.Accounts.User

  describe "changeset/2" do
    test "validates required fields: username, email, password_hash" do
      changeset = User.changeset(struct(User), %{})

      assert "can't be blank" in errors_on(changeset).username
      assert "can't be blank" in errors_on(changeset).email
      assert "can't be blank" in errors_on(changeset).password_hash
    end

    test "validates email format" do
      attrs = valid_attrs(%{email: "not-an-email"})
      changeset = User.changeset(struct(User), attrs)

      assert errors_on(changeset).email
    end

    test "validates username length (3-30)" do
      too_short = User.changeset(struct(User), valid_attrs(%{username: "ab"}))
      too_long = User.changeset(struct(User), valid_attrs(%{username: String.duplicate("a", 31)}))

      assert errors_on(too_short).username
      assert errors_on(too_long).username
    end

    test "validates username allows only alphanumeric and underscore" do
      changeset = User.changeset(struct(User), valid_attrs(%{username: "bad-user!"}))

      assert errors_on(changeset).username
    end
  end

  defp valid_attrs(overrides) do
    uniq = System.unique_integer([:positive])

    Map.merge(
      %{
        username: "valid_user_#{uniq}",
        email: "valid_#{uniq}@example.com",
        password_hash: "$2b$12$abcdefghijklmnopqrstuuN2Q.vABvU8Ga6VJm/6vJf3P6QwPjY7W"
      },
      overrides
    )
  end
end

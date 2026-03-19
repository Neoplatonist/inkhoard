defmodule InkHoard.Libraries.LibraryTest do
  use InkHoard.DataCase, async: true

  alias InkHoard.Libraries.Library

  describe "changeset/2" do
    test "validates required fields: name" do
      changeset = Library.changeset(struct(Library), %{})

      assert "can't be blank" in errors_on(changeset).name
    end

    test "validates name length (1-255)" do
      too_long = Library.changeset(struct(Library), %{name: String.duplicate("a", 256)})

      assert errors_on(too_long).name
    end

    test "with valid attrs produces a valid changeset" do
      changeset = Library.changeset(struct(Library), %{name: "My Library"})

      assert changeset.valid?
    end
  end
end

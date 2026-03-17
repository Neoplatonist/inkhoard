defmodule InkHoard.ExtensionsTest do
  # Hits the real database — must not run async to avoid sandbox conflicts
  # with other DB-mutating tests.
  use InkHoard.DataCase, async: false

  alias Ecto.Adapters.SQL
  alias InkHoard.Repo

  # These three extensions are required before any application table is
  # created.  See design-schema.md §3.6 and migration phase 0.
  @required_extensions ~w[uuid-ossp unaccent pg_trgm]

  describe "PostgreSQL extensions (migration phase 0)" do
    test "all required extensions are enabled in the database" do
      %{rows: rows} =
        SQL.query!(
          Repo,
          "SELECT extname FROM pg_extension",
          []
        )

      installed = Enum.map(rows, fn [name] -> name end)

      Enum.each(@required_extensions, fn ext ->
        assert ext in installed,
               "PostgreSQL extension '#{ext}' is not installed — " <>
                 "run the phase-0 migration (create_extensions)"
      end)
    end

    test "uuid-ossp provides gen_random_uuid() or uuid_generate_v4()" do
      # Smoke-test that the extension is functional, not just registered.
      %{rows: [[uuid]]} =
        SQL.query!(
          Repo,
          "SELECT uuid_generate_v4()",
          []
        )

      assert is_binary(uuid),
             "uuid_generate_v4() did not return a binary value"

      assert {:ok, _} = Ecto.UUID.cast(uuid),
             "uuid_generate_v4() returned a non-UUID value: #{inspect(uuid)}"
    end

    test "unaccent() strips diacritics from accented characters" do
      %{rows: [[result]]} =
        SQL.query!(
          Repo,
          "SELECT unaccent('résumé')",
          []
        )

      assert result == "resume",
             "unaccent('résumé') expected 'resume', got #{inspect(result)}"
    end

    test "pg_trgm provides similarity() function" do
      %{rows: [[score]]} =
        SQL.query!(
          Repo,
          "SELECT similarity('abc', 'abc')",
          []
        )

      assert is_float(score) or is_integer(score),
             "similarity() did not return a numeric value"

      assert score == 1.0,
             "similarity('abc', 'abc') expected 1.0, got #{inspect(score)}"
    end
  end
end

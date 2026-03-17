defmodule InkHoard.DevEnvironmentTest do
  @moduledoc """
  Acceptance tests for Story 0.5 — Development Environment.

  Validates that the dev setup infrastructure is correctly configured:
  docker-compose, mix setup alias, test DB config, support modules, and Mox.
  """
  use InkHoard.DataCase, async: true

  # __DIR__ = apps/api/test/inkhoard/
  @api_root Path.expand("../..", __DIR__)
  @root Path.expand("../../../..", __DIR__)

  describe "docker-compose" do
    test "dev docker-compose file exists with PostgreSQL 15+ service" do
      compose_path = Path.join(@root, "docker-compose.dev.yml")
      assert File.exists?(compose_path), "docker-compose.dev.yml must exist at project root"

      content = File.read!(compose_path)
      assert content =~ "postgres", "docker-compose must define a postgres service"
      assert content =~ ~r/postgres:15/, "docker-compose must use PostgreSQL 15+"
      assert content =~ "5432", "docker-compose must expose port 5432"
    end
  end

  describe "mix setup alias" do
    test "mix.exs defines setup alias with ecto.create, ecto.migrate, and seeds" do
      mix_path = Path.join(@api_root, "mix.exs")
      content = File.read!(mix_path)

      assert content =~ ~r/setup:.*ecto\.setup/s,
             "mix.exs must define a setup alias that runs ecto.setup"

      assert content =~ ~r/ecto\.setup.*ecto\.create.*ecto\.migrate.*seeds/s,
             "ecto.setup must run ecto.create, ecto.migrate, and seeds"
    end
  end

  describe "test database configuration" do
    test "config/test.exs exists with sandbox pool" do
      test_config_path = Path.join(@api_root, "config/test.exs")
      assert File.exists?(test_config_path), "config/test.exs must exist"

      content = File.read!(test_config_path)
      assert content =~ "Ecto.Adapters.SQL.Sandbox", "test config must use SQL Sandbox pool"
      assert content =~ "inkhoard_test", "test config must use inkhoard_test database"
    end

    test "Ecto repo connects and queries successfully" do
      assert {:ok, %{rows: [[1]]}} = InkHoard.Repo.query("SELECT 1")
    end

    test "migrations have been applied" do
      # Verify ecto_schema_migrations table exists (proves ecto.migrate ran)
      assert {:ok, result} =
               InkHoard.Repo.query(
                 "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'schema_migrations'"
               )

      assert result.rows == [[1]], "schema_migrations table must exist"
    end
  end

  describe "test support modules" do
    test "DataCase module is available" do
      assert Code.ensure_loaded?(InkHoard.DataCase),
             "test/support/data_case.ex must define InkHoard.DataCase"
    end

    test "ConnCase module is available" do
      assert Code.ensure_loaded?(InkHoardWeb.ConnCase),
             "test/support/conn_case.ex must define InkHoardWeb.ConnCase"
    end

    test "Mox is configured globally" do
      mocks_path = Path.join(@api_root, "test/support/mocks.ex")
      assert File.exists?(mocks_path), "test/support/mocks.ex must exist"
    end
  end
end

defmodule InkHoard.CIWorkflowTest do
  @moduledoc """
  Acceptance tests for Story 0.4 — CI Pipeline Configuration.

  Validates that the GitHub Actions CI workflow YAML contains the required
  jobs, services, and steps for both backend and frontend quality gates.
  """
  use ExUnit.Case, async: true

  @ci_path Path.expand("../../../../.github/workflows/ci.yml", __DIR__)

  setup_all do
    assert File.exists?(@ci_path),
           "CI workflow file must exist at .github/workflows/ci.yml"

    content = File.read!(@ci_path)
    {:ok, content: content}
  end

  describe "backend job" do
    test "runs mix test with PostgreSQL service container", %{content: content} do
      # Must have a PostgreSQL service definition
      assert content =~ "postgres",
             "CI must define a PostgreSQL service container"

      assert content =~ ~r/image:\s*postgres:15/,
             "PostgreSQL service must use image postgres:15"

      # Must run mix test
      assert content =~ "mix test",
             "CI must run mix test"
    end

    test "runs mix credo --strict", %{content: content} do
      assert content =~ "mix credo --strict",
             "CI must run mix credo --strict"
    end

    test "runs mix format --check-formatted", %{content: content} do
      assert content =~ "mix format --check-formatted",
             "CI must run mix format --check-formatted"
    end

    test "uses Elixir 1.17+ and OTP 27+", %{content: content} do
      assert content =~ ~r/[Ee]lixir.*1\.(1[7-9]|[2-9]\d)/i,
             "CI must use Elixir 1.17 or higher"

      assert content =~ ~r/[Oo][Tt][Pp].*27/i,
             "CI must use OTP 27 or higher"
    end

    test "uses actions/cache for dependency caching", %{content: content} do
      assert content =~ ~r/actions\/cache/,
             "CI must use actions/cache for dependency caching"
    end

    test "runs mix test with coverage", %{content: content} do
      assert content =~ "mix test --cover",
             "CI must run mix test --cover for coverage reporting"
    end
  end

  describe "frontend job" do
    test "runs pnpm test and pnpm build in web directory", %{content: content} do
      assert content =~ "pnpm test" or content =~ "pnpm run test",
             "CI must run pnpm test"

      assert content =~ "pnpm build" or content =~ "pnpm run build",
             "CI must run pnpm build"
    end

    test "uses Node.js 22+", %{content: content} do
      assert content =~ ~r/[Nn]ode.*22/i,
             "CI must use Node.js 22 or higher"
    end
  end

  describe "workflow triggers" do
    test "runs on pull requests", %{content: content} do
      assert content =~ "pull_request",
             "CI must trigger on pull requests"
    end
  end
end

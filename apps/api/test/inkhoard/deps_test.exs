defmodule InkHoard.DepsTest do
  use ExUnit.Case, async: true

  @runtime_apps [
    :phoenix,
    :ecto_sql,
    :postgrex,
    :oban,
    :guardian,
    :joken,
    :cachex,
    :hammer,
    :req,
    :swoosh,
    :vix,
    :prom_ex,
    :jason,
    :corsica,
    :floki,
    :sweet_xml,
    :saxy,
    :xml_builder,
    :nimble_pool,
    :bcrypt_elixir,
    :ex_aws,
    :ex_aws_s3
  ]

  @test_only_apps [:ex_machina, :mox, :stream_data]

  test "all expected runtime applications are available" do
    Enum.each(@runtime_apps, fn app ->
      assert Application.spec(app, :vsn),
             "expected #{inspect(app)} to be available as a dependency"
    end)
  end

  test "test-only applications are available only in :test env" do
    assert Mix.env() == :test

    deps_by_app =
      Mix.Project.config()[:deps]
      |> Enum.map(&normalize_dep/1)
      |> Map.new()

    Enum.each(@test_only_apps, fn app ->
      opts = Map.get(deps_by_app, app)

      assert opts,
             "expected #{inspect(app)} to be declared as a dependency"

      assert Keyword.get(opts, :only) == :test,
             "expected #{inspect(app)} to be restricted to only: :test"
    end)
  end

  defp normalize_dep({app, _requirement, opts}) when is_list(opts), do: {app, opts}
  defp normalize_dep({app, _requirement}), do: {app, []}
end

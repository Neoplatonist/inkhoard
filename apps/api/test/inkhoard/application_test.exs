defmodule InkHoard.ApplicationTest do
  use ExUnit.Case, async: false

  test "application supervision tree includes required children" do
    assert Process.whereis(InkHoard.Supervisor)
    assert Process.whereis(InkHoard.Repo)
    assert Process.whereis(InkHoard.PubSub)
    assert Process.whereis(InkHoardWeb.Endpoint)

    child_ids =
      InkHoard.Supervisor
      |> Supervisor.which_children()
      |> Enum.map(fn {id, _pid, _type, _modules} -> id end)

    assert :"Elixir.Oban" in child_ids
  end
end

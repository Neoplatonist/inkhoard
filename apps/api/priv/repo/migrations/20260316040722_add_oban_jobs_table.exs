defmodule InkHoard.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up, do: Oban.Migrations.up(version: 11)
  def down, do: Oban.Migrations.down(version: 1)
end

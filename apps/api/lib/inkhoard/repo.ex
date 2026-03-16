defmodule InkHoard.Repo do
  use Ecto.Repo,
    otp_app: :inkhoard,
    adapter: Ecto.Adapters.Postgres
end

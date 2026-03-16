defmodule InkHoard.Repo do
  use Ecto.Repo,
    otp_app: :inkhoard,
    adapter: Ecto.Adapters.Postgres

  @spec health_status() :: {:ok, :healthy} | {:error, term()}
  def health_status do
    case Ecto.Adapters.SQL.query(__MODULE__, "SELECT 1", []) do
      {:ok, _result} -> {:ok, :healthy}
      {:error, reason} -> {:error, reason}
    end
  end
end

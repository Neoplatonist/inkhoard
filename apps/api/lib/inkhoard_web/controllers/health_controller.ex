defmodule InkHoardWeb.HealthController do
  use InkHoardWeb, :controller

  def index(conn, _params) do
    repo_module = Application.get_env(:inkhoard, :healthcheck_repo_module, InkHoard.Repo)

    repo_check =
      case repo_module.health_status() do
        {:ok, _details} ->
          %{status: "ok"}

        {:error, reason} ->
          %{
            status: "degraded",
            error: format_health_error(reason)
          }
      end

    overall_status =
      case repo_check.status do
        "ok" -> "ok"
        _ -> "degraded"
      end

    json(conn, %{
      status: overall_status,
      version: app_version(),
      checks: %{
        repo: repo_check
      }
    })
  end

  def live(conn, _params) do
    json(conn, %{status: "alive"})
  end

  def ready(conn, _params) do
    repo_module = Application.get_env(:inkhoard, :healthcheck_repo_module, InkHoard.Repo)

    case repo_module.health_status() do
      {:ok, _details} ->
        json(conn, %{status: "ready"})

      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{
          status: "not_ready",
          error: format_health_error(reason)
        })
    end
  end

  defp app_version do
    :inkhoard
    |> Application.spec(:vsn)
    |> to_string()
  end

  defp format_health_error(%{__exception__: true} = exception) do
    Exception.message(exception)
  end

  defp format_health_error(reason) when is_binary(reason), do: reason
  defp format_health_error(reason), do: inspect(reason)
end

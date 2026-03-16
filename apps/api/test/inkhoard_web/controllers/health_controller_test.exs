defmodule InkHoardWeb.HealthControllerTest do
  use InkHoardWeb.ConnCase, async: true

  describe "GET /healthcheck/live" do
    test "returns 200 with alive status", %{conn: conn} do
      conn = get(conn, "/healthcheck/live")

      assert json_response(conn, 200) == %{"status" => "alive"}
    end
  end

  describe "GET /healthcheck/ready" do
    test "returns 503 when repo health check fails", %{conn: conn} do
      Application.put_env(:inkhoard, :healthcheck_repo_module, __MODULE__.RepoDownStub)

      on_exit(fn ->
        Application.delete_env(:inkhoard, :healthcheck_repo_module)
      end)

      conn = get(conn, "/healthcheck/ready")

      assert json_response(conn, 503)["status"] == "not_ready"
    end
  end

  describe "GET /healthcheck" do
    test "returns 200 with status, version, and checks", %{conn: conn} do
      conn = get(conn, "/healthcheck")
      response = json_response(conn, 200)

      assert Map.has_key?(response, "status")
      assert Map.has_key?(response, "version")
      assert Map.has_key?(response, "checks")
    end
  end

  defmodule RepoDownStub do
    def health_status, do: {:error, :db_down}
  end
end

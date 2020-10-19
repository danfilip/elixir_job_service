defmodule JobServer.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts JobServer.Endpoint.init([])

  # alias JobServer.Test.Utils  TODO: can't read it? why?

  # TODO !! make a macro to generate all tests based on the test request files.

  def read_json(path) do
    with {:ok, body} <- File.read(path),
         {:ok, json} <- Poison.decode!(body), do: {:ok, json}
  end

  setup do
    # File.rm_rf!('./test/test_requests/results')  TODO: leaving this has strange behaviour
    File.mkdir_p!('./test/test_requests/results/tasks')
    File.mkdir_p!('./test/test_requests/results/scripts')
  end

  def make_request(function, json) do
    conn = conn(:post, "/job/#{function}", json)
    conn = JobServer.Endpoint.call(conn, @opts)

    conn
  end

  def test_scenario(scenario, expected_http_rsp) do
    json = read_json("./test/test_requests/#{scenario}.json")

    conn = make_request("sort", json)
    :ok = File.write!("./test/test_requests/results/tasks/#{scenario}.sorted", conn.resp_body)
    assert conn.status == expected_http_rsp

    conn = make_request("script", json)
    :ok = File.write!("./test/test_requests/results/scripts/#{scenario}.script", conn.resp_body)
    assert conn.status == expected_http_rsp

  end

  test "Should fail when a cycle is detected in the dependency graph" do
    test_scenario("cycle", 422);
  end

  test "Should fail because of duplicate task names in the list" do
    test_scenario("duplicate_ids", 422);
  end

  test "sorts the tasks correctly and returns json" do
    json = read_json("./test/test_requests/good.json")

    conn = conn(:post, "/job/sort", json)

    # Invoke the plug
    conn = JobServer.Endpoint.call(conn, @opts)

    # Assert the response
    :ok = File.write!("./test/test_requests/results/tasks/good.sorted", conn.resp_body)

    assert conn.status == 200
  end

  test "sorts the tasks and returns text script" do
    json = read_json("./test/test_requests/good.json")

    conn = conn(:post, "/job/script", json)

    # Invoke the plug
    conn = JobServer.Endpoint.call(conn, @opts)

    # Assert the response
    :ok = File.write!("./test/test_requests/results/scripts/good.script", Poison.decode!(conn.resp_body))

    assert conn.status == 200
  end

  # test "it returns 422 with an invalid payload" do
  #   # Create a test connection
  #   conn = conn(:post, "/events", %{})

  #   # Invoke the plug
  #   conn = JobServer.Endpoint.call(conn, @opts)

  #   # Assert the response
  #   assert conn.status == 422
  # end

  test "404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = JobServer.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end

end

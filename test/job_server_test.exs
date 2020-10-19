defmodule JobServer.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts JobServer.Endpoint.init([])

  # alias JobServer.Test.Utils  TODO: can't read it? why?

  def read_json(path) do
    with {:ok, body} <- File.read(path),
         {:ok, json} <- Poison.decode!(body), do: {:ok, json}
  end

  test "sorts the tasks correctly and returns json" do
    json = read_json("./test/test_requests/good.json")

    conn = conn(:post, "/job/sort", json)

    # Invoke the plug
    conn = JobServer.Endpoint.call(conn, @opts)

    # Assert the response
    File.write!("./test/test_requests/good.sorted", conn.resp_body)

    assert conn.status == 200
  end

  test "sorts the tasks and returns text script" do
    json = read_json("./test/test_requests/good.json")

    conn = conn(:post, "/job/script", json)

    # Invoke the plug
    conn = JobServer.Endpoint.call(conn, @opts)

    # Assert the response
    File.write!("./test/test_requests/good.script", Poison.decode!(conn.resp_body))

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

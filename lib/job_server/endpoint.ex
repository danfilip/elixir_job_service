defmodule JobServer.Endpoint do
  @moduledoc """
    A Plug for job processing and task sorting
  """
  use Plug.Router

  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)
  # responsible for matching routes
  plug(:match)
  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  # responsible for dispatching responses
  plug(:dispatch)

  alias JobServer.Services.JobService
  alias JobServer.TaskUtils

  # Sorts the tasks in topological order
  post "/job/sort" do
    require Logger

    Logger.debug("Received: #{inspect(conn.body_params)}")

    with {:ok, tasks} <- TaskUtils.validate_tasks(conn.body_params),
         {:ok, task_map} <- TaskUtils.to_task_map(tasks),
         {:ok, ordered_task_names} <- JobService.sort_tasks(task_map),
         {:ok, result} <- TaskUtils.tasks_to_map(ordered_task_names, task_map) do
        #  {:ok, result} <- TaskUtils.tasks_to_script(ordered_task_names, task_map) do

      send_resp(conn, 200, Poison.encode!(result))
    else
      {:error, message} -> send_resp(conn, 422, message)
    end

  end

  # sorts the tasks topologically then generates plain text script
  post "/job/script" do
    require Logger

    Logger.debug("Received: #{inspect(conn.body_params)}")

    with {:ok, tasks} <- TaskUtils.validate_tasks(conn.body_params),
         {:ok, task_map} <- TaskUtils.to_task_map(tasks),
         {:ok, ordered_task_names} <- JobService.sort_tasks(task_map),
         {:ok, result} <- TaskUtils.tasks_to_script(ordered_task_names, task_map) do

      send_resp(conn, 200, Poison.encode!(result))
    else
      {:error, message} -> send_resp(conn, 422, message)
    end

  end

  # A catchall route to handle inexistent paths
  match _ do
    send_resp(conn, 404, "Nothing here")
  end

end

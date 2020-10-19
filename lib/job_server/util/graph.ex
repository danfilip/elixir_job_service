defmodule Graph do

  @spec build_graph(any, any, any) :: {:ok, :digraph.graph()}
  @doc """
  Builds a graph from a list of Task structs.
  Should also receive 2 other functions : one to get the ID of the task and one to get the dependencies of a task
  """
  def build_graph(object_map, _get_id_fn, get_dependencies_fn) do
    graph = :digraph.new()

    Enum.each(object_map, fn ({name, _task}) ->
      # IO.puts("Add Vertex: #{inspect(name)}")
      :digraph.add_vertex(graph, name)
    end)

    Enum.each(object_map, fn ({name, task}) ->
      Enum.each(get_dependencies_fn.(task), fn dep ->
        # IO.puts("** Add edge between: #{inspect(dep)} -> #{inspect(name)} \n")
        :digraph.add_edge(graph, dep, name)  # TODO returns :error in case one of the vertices does not exist
      end)
    end)

    {:ok, graph}
  end

  @spec sort(:digraph.graph()) :: false | [list(Task)]
  def sort(graph) do
    :digraph_utils.topsort(graph)
  end

end

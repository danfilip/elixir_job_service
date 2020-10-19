defmodule JobServer.Services.JobService do

  alias Graph

  @doc """
  Sorts a map of Task objects in topological order
  Returns a list of task names sorted topologically
  """
  def sort_tasks(task_map) do

    with {:ok, graph} <- Graph.build_graph(task_map, fn task -> task.name end , fn task -> task.requires || [] end ),
         sorted_task_list when is_list(sorted_task_list) <- Graph.sort(graph) do

        {:ok, sorted_task_list}
    else
        false -> {:error, "Graph could not be sorted.Probably it's not a DAG.."}
        _     -> {:error, "Something went wrong, dependency graph could not be built"}
    end

  end

  @doc """
   - validate require list is subset(matches) of tasklist
   - validate non empty task names, non duplicate task names, non empty and existing req
  """
  def validate_tasks(task_list) do

    not_empty = fn string -> String.trim(string) !== "" end

    task_set = task_list
                |> Enum.filter(fn task -> not_empty.(task["name"]) end)  # how to get func ref here? &not_empty. ?
                |> Enum.map(fn task -> task["name"] end)
                |> MapSet.new

    required_set =  task_list
                    |> Enum.reduce([], fn task, acc -> (task["requires"] || []) ++ acc end)
                    |> Enum.filter(fn dependency -> not_empty.(dependency) end)  # how to get func ref here? &not_empty. ?
                    |> MapSet.new

    cond do
      MapSet.size(task_set) < length(task_list) -> {:error,  "invalid task list(either empty or duplicate keys found)"}
      !MapSet.subset?(required_set, task_set)   -> {:error,  "errors in required tasks: non existing required task was referenced"}
      true -> {:ok, task_list}
    end

  end

end

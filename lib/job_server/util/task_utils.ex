defmodule JobServer.TaskUtils do

  alias JobServer.Task

  @doc """
  Transforms the list of maps into a list of Task structs
  """
  def to_task_map(tasks) do
    # 1. build am map between of name => Task objects
    name_to_task = Enum.into(tasks, %{}, fn task -> {task["name"], %Task{name: task["name"], command: task["command"], requires: task["requires"] || [] }} end)

    {:ok, name_to_task}
  end

  @doc """
  Validates tha list of tasks for consistency:
   - validate require list is subset(matches) of tasklist
   - validate non empty task names, non duplicate task names, non empty and existing req

   TODO check out https://github.com/vic/params for param validation?!
  """
  def validate_tasks(task_map) do

    %{"tasks" => task_list} = task_map # TODO : try catch? to handle missing "tasks" prop

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
      MapSet.size(task_set) < length(task_list) -> {:error, "invalid task list(either empty or duplicate keys found)"}
      !MapSet.subset?(required_set, task_set)   -> {:error, "errors in required tasks: non existing required task was referenced"}
      true -> {:ok, task_list}
    end

  end

  @doc """
  Transforms a list of Task struct objects into the expected map
  """
  def tasks_to_map(task_list, task_map) do
    ret_map = %{"tasks" => Enum.map(task_list, fn task_id -> %{"name" => task_map[task_id].name, "command" => task_map[task_id].command} end) }

    {:ok, ret_map} # maybe don't return tuple
  end

  def tasks_to_script(task_list, task_map) do
    lines = task_list
      |> Enum.map(fn task_name -> task_map[task_name].command end)
      |> Enum.join("\n")

    script = "#/bin/bash\n" <> lines  # could use this to look more confusing:  ~s(#/bin/bash\n#{lines})

    {:ok, script}
  end

end

defmodule JobServer.Task do
  @enforce_keys [:name, :command]
  defstruct [:name, :command, requires: []]

  # def create(namex, commandx, requiresx) do TODO: should/could it be here?
  #   %Task{name: namex, command: commandx, requires: requiresx }
  # end
end

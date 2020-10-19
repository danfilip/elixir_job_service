defmodule JobServer.Test.Utils do
  import Poison

  def read_json(path) do
    with {:ok, body} <- File.read(path),
         {:ok, json} <- Poison.decode!(body), do: {:ok, json}
  end

end

defmodule Todo.ProcessRegistry do
  use GenServer

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:register_name, key, pid}, _, registry) do
    case Map.get(registry, key) do
      nil ->  # Key not yet present
        Process.monitor(pid)
        {:reply, :yes, Map.put(registry, key, pid)}
      _ ->  # Key already in registry
        {:reply, :no, registry}
    end
  end

  def handle_call({:whereis_name, key}, _, registry) do
    {
      :reply,
      Map.get(registry, key, :undefined),
      registry
    }
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, registry) do
    {:noreply, dereg(registry, pid)}
  end

  def dereg(registry, pid) do
    Enum.filter(registry, fn {_key, value} ->
      value != pid end)
    |> Enum.into(%{})
  end

end

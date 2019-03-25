defmodule Todo.ProcessRegistry do
  use GenServer
  import Kernel, except: [send: 2]

  # Server Functions
  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:register_name, key, pid}, _from, registry) do
    case Map.get(registry, key) do
      nil ->  # Key not yet present
        Process.monitor(pid)
        {:reply, :yes, Map.put(registry, key, pid)}
      _ ->  # Key already in registry
        {:reply, :no, registry}
    end
  end

  def handle_call({:whereis_name, key}, _from, registry) do
    {
      :reply,
      Map.get(registry, key, :undefined),
      registry
    }
  end

  def handle_cast({:unregister_name, key}, registry) do
    {:noreply, Map.delete(registry, key)}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, registry) do
    {:noreply, dereg_pid(registry, pid)}
  end

  defp dereg_pid(registry, pid) do
    Enum.filter(registry, fn {_key, value} ->
      value != pid end)
    |> Enum.into(%{})
  end

  # Interface functions
  def start_link do
    IO.puts "Starting process registry."
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.cast(:process_registry, {:unregister_name, key})
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

end

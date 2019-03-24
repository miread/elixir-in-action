defmodule Todo.Cache do
  use GenServer

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, list_name}, _, serv_list) do
    case Map.fetch(serv_list, list_name) do
      {:ok, value} -> {:reply, value, serv_list}
      :error ->
        {:ok, pid} = Todo.Server.start_link(list_name)
        {:reply, pid, Map.put(serv_list, list_name, pid)}
    end
  end

  #Interface functions
  def start_link do
    IO.puts "Starting to-do cache."
    GenServer.start_link(__MODULE__, nil, name: :cache_id)
  end

  def server_process(todo_name) do
    GenServer.call(:cache_id, {:server_process, todo_name})
  end
end

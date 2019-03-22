defmodule Todo.Cache do
  use GenServer

  def init(_) do
    Todo.Database.start("./persist/")
    {:ok, %{}}
  end

  def handle_call({:server_process, list_name}, _, serv_list) do
    case Map.fetch(serv_list, list_name) do
      {:ok, value} -> {:reply, value, serv_list}
      :error ->
        {:ok, pid} = Todo.Server.start(list_name)
        {:reply, pid, Map.put(serv_list, list_name, pid)}
    end
  end

  #Interface functions
  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_name) do
    GenServer.call(cache_pid, {:server_process, todo_name})
  end
end

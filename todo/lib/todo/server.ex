defmodule Todo.Server do
  use GenServer

  def start(list_name) do
    GenServer.start(Todo.Server, list_name)
  end

  def init(list_name) do
    {:ok, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
  end

  def put(pid, new_entry) do
    GenServer.cast(pid, {:put, new_entry})
  end

  def get(pid, date) do
    GenServer.call(pid, {:get, date})
  end

  def handle_cast({:put, new_entry}, {list_name, list}) do
    new_state = Todo.List.add_entry(list, new_entry)
    Todo.Database.store(list_name, new_state)
    {:noreply, {list_name, new_state}}
  end

  def handle_call({:get, date}, _, {list_name, list}) do
    {:reply, Todo.List.entries(list, date), {list_name, list}}
  end

end

defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(TodoServer, nil)
  end

  def init(_) do
    {:ok, TodoList.new()}
  end

  def put(pid, new_entry) do
    GenServer.cast(pid, {:put, new_entry})
  end

  def get(pid, date) do
    GenServer.call(pid, {:get, date})
  end

  def handle_cast({:put, new_entry}, state) do
    {:noreply, TodoList.add_entry(state, new_entry)}
  end

  def handle_call({:get, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
  end

end

#-------------

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry) do
      #Adds ID to new entry
      entry = Map.put(entry, :id, auto_id)
      #Adds the new entry to the existing entries list
      new_entries = Map.put(entries, auto_id, entry)
      #Updates the struct - new entry + prepare next ID
      %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

end

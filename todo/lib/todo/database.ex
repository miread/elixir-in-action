defmodule Todo.Database do
  use GenServer

  def init(path) do
    {:ok, worker_1} = Todo.DatabaseWorker.start(path)
    {:ok, worker_2} = Todo.DatabaseWorker.start(path)
    {:ok, worker_3} = Todo.DatabaseWorker.start(path)
    {:ok, %{0 => worker_1, 1 => worker_2, 2 => worker_3}}
  end

  def handle_call({:get, key}, caller, state) do
    data = Todo.DatabaseWorker.get(
      get_worker(state, :erlang.phash2(key, 3)),
      key
    )
    GenServer.reply(caller, data)

    {:noreply, state}
  end

  def handle_cast({:store, key, value}, state) do
    Todo.DatabaseWorker.store(
      get_worker(state, :erlang.phash2(key, 3)),
      key, value
    )
    {:noreply, state}
  end

  def get_worker(state, index) do
    Map.get(state, index)
  end


  #Interface
  def start(path) do
    GenServer.start(__MODULE__, path, name: :db_id)
  end

  def get(key) do
    GenServer.call(:db_id, {:get, key})
  end

  def store(key, value) do
    GenServer.cast(:db_id, {:store, key, value})
  end

end

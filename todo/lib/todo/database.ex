defmodule Todo.Database do
  @pool_size 3

  #Interface
  def start_link(path) do
    IO.puts "Starting database server."
    Todo.PoolSupervisor.start_link(path, @pool_size)
  end

  def get(key) do
    choose_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  def store(key, value) do
    choose_worker(key)
    |> Todo.DatabaseWorker.store(key, value)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

end

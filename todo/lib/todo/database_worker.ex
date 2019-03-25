defmodule Todo.DatabaseWorker do
  use GenServer

  def init(path) do
    File.mkdir_p(path)
    {:ok, path}
  end

  defp file_name(path, file) do
    "#{path}/#{file}"
  end

  defp via_tuple(worker_id) do
    {:via, Todo.ProcessRegistry, {:database_worker, worker_id}}
  end

  def handle_call({:get, key}, caller, path) do
    data = case File.read(file_name(path, key)) do
             {:ok, contents} -> :erlang.binary_to_term(contents)
             _ -> nil
           end

    GenServer.reply(caller, data)
    {:noreply, path}
  end

  def handle_cast({:store, key, value}, path) do
    File.write!(file_name(path, key), :erlang.term_to_binary(value))
    {:noreply, path}
  end

  #Interface
  def start_link(path, worker_id) do
    IO.puts "Starting database worker #{worker_id}."
    GenServer.start_link(__MODULE__, path, name: via_tuple(worker_id))
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def store(worker_id, key, value) do
    GenServer.cast(via_tuple(worker_id), {:store, key, value})
  end

end

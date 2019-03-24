defmodule Todo.DatabaseWorker do
  use GenServer

  def init(path) do
    File.mkdir_p(path)
    {:ok, path}
  end

  defp file_name(path, file) do
    "#{path}/#{file}"
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
  def start_link(path) do
    IO.puts "Starting database worker."
    GenServer.start_link(__MODULE__, path)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def store(pid, key, value) do
    GenServer.cast(pid, {:store, key, value})
  end

end

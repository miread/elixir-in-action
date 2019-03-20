defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  # Issues requests to the server process
  def call(pid, request) do
    send(pid, {request, self()})
    receive do
      {:response, response} -> response
    end
  end

  # Powers the process, waits for messages, and handles them
  defp loop(callback_module, state) do
    receive do
      # Invokes callback module to handle the request
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(
          request, state)
        # Sends the response back
        send(caller, {:response, response})
        # Loops with new state
        loop(callback_module, new_state)
    end
  end

end

# Test Module
defmodule KeyValueStore do
  # Internal, creates base structure
  def init do
    %{}
  end

  # Three helper/interface functions
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.call(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  # Two callback functions to internally handle the data state
  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end

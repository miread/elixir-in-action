defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  # Issues requests to the server process
  def call(pid, request) do
    send(pid, {:call, request, self()})
    receive do
      {:response, response} -> response
    end
  end

  # Issues cast messages
  def cast(pid, request) do
    send(pid, {:cast, request})
  end

  # Powers the process, waits for messages, and handles them
  defp loop(callback_module, state) do
    receive do
      # Invokes callback module to handle the request
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(
          request, state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      # Cast messages do not send response
      {:cast, request} ->
        new_state = callback_module.handle_cast(
          request,
          state
        )
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

  # Put uses cast since it requires no response
  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  # Two callback functions to internally handle the data state
  def handle_cast({:put, key, value}, state) do
    Map.put(state, key, value)
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end

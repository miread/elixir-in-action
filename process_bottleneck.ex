defmodule Server do
  def start do
    spawn(fn -> loop end)
  end

  def send_msg(server, message) do
    send(server, {self, message})
    receive do
      {:response, response} -> response
    end
  end

  defp loop do
    receive do
      {caller, msg} ->
        :timer.sleep(1000)  # Simulates long processing
        send(caller, {:response, msg})
    end
    loop
  end
end

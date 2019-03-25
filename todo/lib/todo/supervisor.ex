defmodule Todo.Supervisor do
  use Supervisor

  def init(_) do
    # List of supervised processes:
    children = [
      %{id: ProcessRegistry, start: {Todo.ProcessRegistry, :start_link, []}},
      %{id: Database, start: {Todo.Database, :start_link, ["./persist/"]}},
      %{id: Cache, start: {Todo.Cache, :start_link, []}}
    ]
    # Supervisor specification
    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link do
    IO.puts "Starting Supervisor."
    Supervisor.start_link(__MODULE__, nil, name: :sup_id)
  end

end

defmodule Todo.PoolSupervisor do
  use Supervisor

  def init({path, pool_size}) do
    children = for id <- 1..pool_size do
      %{id: {:database_worker, id},
        start: {Todo.DatabaseWorker, :start_link, [path, id]}
      }
    end
    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link(path, pool_size) do
    Supervisor.start_link(__MODULE__, {path, pool_size})
  end
end

defmodule Todo.System do
  use Supervisor

  def init(_) do
    Supervisor.init([Todo.Cache], strategy: :one_for_one) 
  end

  def start_link() do
     Supervisor.start_link(
      [Todo.Cache],
      strategy: :one_for_one
     ) 
  end
   
end


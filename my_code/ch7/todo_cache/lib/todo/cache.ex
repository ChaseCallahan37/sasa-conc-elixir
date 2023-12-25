defmodule Todo.Cache do
  use GenServer
  
  def start() do
    GenServer.start(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def server_process(cache, list_name) do
    GenServer.call(cache, {:server_process, list_name})
  end

  @impl true
  def handle_call({:server_process, list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error -> 
        {:ok, new_server} = Todo.Server.start()

        {
          :reply,
          new_server,
          Map.put(todo_servers, list_name, new_server)
        }
    end
  end
end

defmodule KeyValueStore do
  use GenServer
  def start() do
    {:ok, pid} = GenServer.start(KeyValueStore, nil)
    pid
  end
  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  def put(server, key, value) do
    GenServer.cast(server, {:put, key, value}) 
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_info(:cleanup, state) do
    IO.puts "performing cleanup ..."
    {:noreply, state}
  end
end

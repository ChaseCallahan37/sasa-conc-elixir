defmodule Todo.Server do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  @impl true 
  def init(_) do
    {:ok, Todo.List.new()}
  end

  def add(server, entry) do
    GenServer.cast(server, {:add, entry})
  end

  def remove(server, id) do
    GenServer.cast(server, {:remove, id})
  end

  def update(server, entry) do
    GenServer.cast(server, {:update, entry})
  end

  def entries(server, date) do
    GenServer.call(server, {:get, date})
  end

  @impl true
  def handle_cast({:add, entry}, state) do
    {:noreply, Todo.List.add_entry(state, entry)}
  end

  @impl true
  def handle_cast({:remove, id}, state) do
    {:noreply, Todo.List.delete_entry(state, id)}
  end

  @impl true
  def handle_cast({:update, entry}, state) do
    {:noreply, Todo.List.update(state, entry)}
  end

  @impl true
  def handle_call({:get, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end



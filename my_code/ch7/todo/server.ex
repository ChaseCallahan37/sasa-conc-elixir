defmodule Todo.Server do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl true 
  def init(_) do
    {:ok, Todo.List.new()}
  end

  def add(entry) do
    GenServer.cast(__MODULE__, {:add, entry})
  end

  def remove(id) do
    GenServer.cast(__MODULE__, {:remove, id})
  end

  def update(entry) do
    GenServer.cast(__MODULE__, {:update, entry})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:get, date})
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



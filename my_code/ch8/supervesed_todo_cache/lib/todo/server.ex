defmodule Todo.Server do
  use GenServer

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name)
  end

  @impl true 
  def init(list_name) do
    send(self(), {:real_init, list_name})
    {:ok, nil}
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
  def handle_cast({:add, entry}, {name, list}) do
    new_list = Todo.List.add_entry(list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl true
  def handle_cast({:remove, id}, {name, list}) do
    new_list = Todo.List.delete_entry(list, id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl true
  def handle_cast({:update, entry}, {name, list}) do
    new_list = Todo.List.update(list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl true
  def handle_call({:get, date}, _, {_, list} = state) do
    {:reply, Todo.List.entries(list, date), state}
  end

  @impl true
  def handle_info({:real_init, list_name}, _) do
    {:noreply, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
  end

end



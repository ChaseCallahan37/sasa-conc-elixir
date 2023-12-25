defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start_link do
    IO.puts("Starting database server")
    GenServer.start_link(__MODULE__, nil,
     name: __MODULE__
    )
  end

  @impl true
  def init(_) do
    File.mkdir_p!(@db_folder)
    send(self(), {:real_init})
    {:ok, nil} 
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  @impl true
  def handle_call({:get, key}, caller, workers) do
    worker = choose_worker(key, workers)
    spawn(fn -> 
      contents = Todo.DatabaseWorker.read(worker, key)
      GenServer.reply(caller, contents)
    end)

    {:noreply, workers}
  end

  @impl true
  def handle_cast({:store, key, data}, workers) do
    worker = choose_worker(key, workers)
    Todo.DatabaseWorker.write(worker, key, data)
    {:noreply, workers}
  end

  @impl true
  def handle_info({:real_init}, _) do
    File.mkdir_p(@db_folder)
    
    workers = 0..2 
      |> Stream.map(fn index -> {index, Todo.DatabaseWorker.start_link(@db_folder)} end)
      |> Enum.reduce(%{}, fn {index, {:ok, worker}}, workers ->
          Map.put(workers, index, worker)
         end)

    {:noreply, workers}
 
  end

  def choose_worker(key, workers) do
    Map.fetch!(workers, :erlang.phash2(key, 3))
  end
end

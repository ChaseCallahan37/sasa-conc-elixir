defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  @impl true
  def init(db_folder) do
    
   {:ok, db_folder}
  end

  def read(worker, list_name) do
    GenServer.call(worker, {:read, list_name})
  end

  def write(worker, list_name, data) do
    GenServer.cast(worker, {:write, list_name, data})
  end

  @impl true
  def handle_call({:read, list_name}, caller, db_folder) do
    spawn(fn ->
      data = case file_name(db_folder, list_name) |> File.read() do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

      GenServer.reply(caller, data)
    end)
    {:noreply, db_folder}
  end 

  @impl true
  def handle_cast({:write, list_name, data}, db_folder) do
    file_name(db_folder, list_name)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end 
  
  def file_name(db_folder, list_name) do
    Path.join(db_folder, to_string(list_name))
  end
end

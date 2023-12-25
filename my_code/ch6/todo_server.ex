defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn -> 
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end
  
  def loop(callback_module, curr_state) do
    receive do
      {:call, request, caller} -> 
        {response, new_state} =
          callback_module.handle_call(
            request,
            curr_state
        )

        send(caller, {:response, response})
        loop(callback_module, new_state)
    
      {:cast, request} -> 
        new_state = callback_module.handle_cast(
          request,
          curr_state
        )

        loop(callback_module, new_state)
    end
  end

  def call(server, request) do
    send(server, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server, request) do
    send(server, {:cast, request})
  end
end


defmodule TodoServer do
  def init(), do: TodoList.new()

  def start() do
    Process.register(ServerProcess.start(TodoServer), :todo_server)
  end

  def add(entry) do
    ServerProcess.cast(:todo_server, {:add, entry})
  end

  def get(date) do
    ServerProcess.call(:todo_server, {:get, date}) 
  end

  def update(entry) do
    ServerProcess.call(:todo_server, {:put, entry})
  end

  def handle_call({:get, date}, curr_state) do
    {TodoList.entries(curr_state, date), curr_state}
  end

  def handle_call({:put, entry}, todo_list) do
    {:ok, TodoList.update(todo_list, entry)}
  end

  def handle_cast({:add, entry}, curr_state) do
    TodoList.add_entry(curr_state, entry)
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(%TodoList{} = todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update(%TodoList{} = todo_list, new_entry) do
    update(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update(%TodoList{} = todo_list, id, update_fun) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        {:error, todo_list}

      {:ok, %{id: old_id} = old_entry} ->
        new_entry = %{id: ^old_id} = update_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{} = todo_list, id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, id)}
  end

  defimpl Collectable, for: TodoList do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      TodoList.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(_, :halt), do: :ok
  end
end

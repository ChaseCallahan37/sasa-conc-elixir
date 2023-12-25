defmodule TodoServer do
  def start() do
    Process.register(spawn(fn -> loop(TodoList.new()) end), :todo_server)
  end

  def loop(todo_list) do
    new_todo_list = 
    receive do
      message -> process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  def process_message(todo_list, {:add, entry}), do: TodoList.add_entry(todo_list, entry)
  def process_message(todo_list, {:remove, id}), do: TodoList.delete_entry(todo_list, id)
  def process_message(todo_list, {:update, entry}), do: TodoList.update(todo_list, entry)
  
  def process_message(todo_list, {:get, caller, date}) do
    send(caller, {:result, TodoList.entries(todo_list, date)})
    todo_list
  end

  def add_entry(entry) do
    send(:todo_server, {:add, entry})
  end

  def entries(date) do
    send(:todo_server, {:get, self(), date})

    receive do
      {:result, entries} -> entries
    after
      5000 -> IO.puts("Server timeout")
    end
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

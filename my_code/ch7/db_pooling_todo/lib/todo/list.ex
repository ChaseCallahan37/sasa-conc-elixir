defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(%Todo.List{} = todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update(%Todo.List{} = todo_list, new_entry) do
    update(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update(%Todo.List{} = todo_list, id, update_fun) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        {:error, todo_list}

      {:ok, %{id: old_id} = old_entry} ->
        new_entry = %{id: ^old_id} = update_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%Todo.List{} = todo_list, id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, id)}
  end

  defimpl Collectable, for: Todo.List do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      Todo.List.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(_, :halt), do: :ok
  end
end

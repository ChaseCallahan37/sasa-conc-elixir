defmodule TodoList.CsvImporter do

  def read(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&parse_line(&1))
    |> TodoList.new()
      
  end

  defp parse_line([date, title] = entry) do
    %{date: DateTime.from_iso8601(date), title: title}
  end
  
end

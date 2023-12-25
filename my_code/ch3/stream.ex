defmodule StreamEx do
  def lines_length!(path) do
    File.stream!(path)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&(String.length(&1)))
  end
  def longest_line_length(path) do
    lines_length!(path)
    |> Enum.max()
    
  end

  def longest_line(path) do
    File.stream!(path)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&({String.length(&1), &1}))
    |> Enum.max_by(fn {n, _line} -> n end)
  end
  def words_per_line!(path) do
    File.stream!(path)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&(String.split(&1) |> Enum.count()))
    |> Enum.to_list() 
  end
end

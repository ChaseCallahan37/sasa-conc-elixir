defmodule Nums do
  def print(n) when n < 0, do: {:error, "Please only provide a number 1 or above"}
  def print(1), do: IO.puts(1)
  def print(n) do
    print(n - 1)
    IO.puts(n)
  end
    
end

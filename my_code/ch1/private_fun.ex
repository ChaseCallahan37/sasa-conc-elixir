defmodule TestPrivate do
  alias IO, as: MyIO

  def double(a) do
    sum(a, a)
  end
    
  defp sum(a, b) do
    a + b 
  end
  
  def show(a) do
    MyIO.puts(a) 
  end
end

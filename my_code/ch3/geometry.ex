defmodule Geometry do
  def area({:square, a}) do
    a * a
  end

  def area({:circle, a}) do
    (a * a) * 3.14 
  end

  def area({:rectangle, a, b}) do
    a * b
  end
  
  def area(unknown) do
    {:error, {:unknown_shape, unknown}}
  end
end

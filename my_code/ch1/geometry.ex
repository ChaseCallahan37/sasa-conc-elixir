defmodule Geometry do
  defmodule Rectangle do
    def area(a), do: area(a, a)
    def area(a, b), do: a * b
  end

  defmodule Square do
    def area(a) do
      Rectangle.area(a, a)
    end
  end
end

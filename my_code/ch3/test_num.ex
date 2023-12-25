defmodule TestNum do
  def test(n) when is_number(n) and n < 0 do
    :negative
  end
  def test(0) do
    :zero
  end
  def test(n) when is_number(n) and  n > 0 do
    :positive
  end
end

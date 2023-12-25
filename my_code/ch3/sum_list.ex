defmodule ListHelper do
  def sum_non_tail([]), do: 0
  def sum_non_tail([n | tail]), do: n + sum_non_tail(tail)

  def sum(list), do: do_sum(0, list)

  defp do_sum(sum, []) do
    sum
  end
  defp do_sum(sum, [n | tail]) do
    do_sum(sum + n, tail)
  end

  def list_len(list), do: calc_list_len(0, list)
  
  defp calc_list_len(sum, []), do: sum
  defp calc_list_len(sum, [_| tail]), do: calc_list_len(sum + 1, tail) 
    
  def range([]), do: 0
  def range([head|tail]), do: calc_range(head, head, tail)

  defp calc_range(min, max, []), do: max - min
  defp calc_range(min, max, [head|tail]) when head > max, do: calc_range(min, head, tail)
  defp calc_range(min, max, [head|tail]) when head < min, do: calc_range(head, max, tail)
  defp calc_range(min, max, [_|tail]), do: calc_range(min, max, tail)

  def positive(list), do: calc_positive([], list)

  defp calc_positive(positives, []), do: List.flatten(positives)
  defp calc_positive(positives, [head|tail]) when head > 0, do: calc_positive([positives, head], tail)
  defp calc_positive(positives, [_|tail]), do: calc_positive(positives, tail)
    

end

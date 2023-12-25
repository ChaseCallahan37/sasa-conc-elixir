defmodule CalculatorServer do
  def start do
    spawn(fn -> loop(0) end)
  end

  def loop(curr_value) do
    new_value = 
    receive do
      message -> process_message(curr_value, message)
    end

    loop(new_value)
  end

  def process_message(curr_value, {:value, caller}) do
    send(caller, {:response, curr_value})
    curr_value
  end

  def process_message(curr_value, {:add, n}), do: curr_value + n
  def process_message(curr_value, {:sub, n}), do: curr_value - n
  def process_message(curr_value, {:mult, n}), do: curr_value * n
  def process_message(curr_value, {:div, n}), do: curr_value / n
  
  def process_message(curr_value, invalid_request) do
    IO.puts("#{inspect invalid_request} is invalid")
    curr_value
  end

  def add(server_pid, n), do: send(server_pid, {:add, n})
  def sub(server_pid, n), do: send(server_pid, {:sub, n})
  def mult(server_pid, n), do: send(server_pid, {:mult, n})
  def div(server_pid, n), do: send(server_pid, {:div, n})

  def get_result(server_pid) do
    send(server_pid, {:value, self()})
    receive do
      {:response, curr_value} -> curr_value
    after
      5000 -> IO.puts("Timeout error")
    end
  end

end

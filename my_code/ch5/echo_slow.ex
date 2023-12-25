defmodule EchoServer do
  def start() do
    Process.register(spawn(fn -> loop() end), :echo_server)
  end

  def loop() do
    receive do
    {caller, msg} -> 
        Process.sleep(1000)
        send(caller, {:response, msg})
    end

    loop()
  end

  def send_msg(msg) do
    send(:echo_server, {self(), msg})

    receive do
      {:response, msg} -> msg
    after
      5000 -> IO.puts("Server Timeout")
    end
  end
end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn -> 
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end
  
  def loop(callback_module, curr_state) do
    receive do
      {:call, request, caller} -> 
        {response, new_state} =
          callback_module.handle_call(
            request,
            curr_state
        )

        send(caller, {:response, response})
        loop(callback_module, new_state)
    
      {:cast, request} -> 
        new_state = callback_module.handle_cast(
          request,
          curr_state
        )

        loop(callback_module, new_state)
    end
  end

  def call(server, request) do
    send(server, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server, request) do
    send(server, {:cast, request})
  end
end

defmodule KeyValueStore do
  def start() do
    ServerProcess.start(KeyValueStore)
  end

  def init(), do: %{}

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def handle_cast({:put, key, value}, curr_state) do
    Map.put(curr_state, key, value)
  end

  def handle_call({:get, key}, curr_state) do
    {{:ok,  Map.get(curr_state, key)}, curr_state}
  end
end

defmodule SupervesedTodoCacheTest do
  use ExUnit.Case
  doctest SupervesedTodoCache

  test "greets the world" do
    assert SupervesedTodoCache.hello() == :world
  end
end

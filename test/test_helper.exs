# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License

ExUnit.start()

# Simply pass invoming data to all linked nodes
defmodule Broadcaster do
  @behaviour DataMesh.NodeLogic

  def process(data, state, broadcast) do
    broadcast.(data)
    {:ok, state}
  end
end

# Collecting all received data until a :broadcast or a :reset
defmodule Collector do
  @behaviour DataMesh.NodeLogic

  def init(test_pid) do
    {:ok, []}
  end

  def process(:reset, state, _broadcast) do
    {:ok, []}
  end

  def process(:broadcast, state, broadcast) do
    broadcast.(state)
    {:ok, state}
  end

  def process(data, state, _broadcast) do
    new_state = [data | state]
    {:ok, new_state}
  end

  def retrieve(state) do
    {:ok, state}
  end
end

# Countown until zero and broadcast the configured data
defmodule Countdowner do
  @behaviour DataMesh.NodeLogic

  def init({count, data}) do
    {:ok, %{start: count, data: data}}
  end

  def process(_data, state, broadcast) do
    new_state =
      if state.count == 1 do
        broadcast.(state.data)
        %{state | count: state.start}
      else
        %{state | count: state.count - 1}
      end

    {:ok, new_state}
  end
end

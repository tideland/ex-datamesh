# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License

ExUnit.start()

defmodule Broadcaster do
  @behaviour DataMesh.NodeLogic

  # Simply pass to subscribers
  def process(data, state, broadcast) do
    broadcast.(data)
    {:ok, state}
  end
end

defmodule Collector do
  @behaviour DataMesh.NodeLogic

  def init(test_pid) do
    {:ok,
     %{
       test_pid: test_pid,
       collection: []
     }}
  end

  # Send data to registered pid
  def process(:send, state, _broadcast) do
    send(state.test_pid, {:received, state.collection})
    {:ok, state}
  end

  # Collect data
  def process(data, state, _broadcast) do
    new_state = %{state | collection: [data | state.collection]}
    {:ok, new_state}
  end
end

defmodule CountDowner do
  @behaviour DataMesh.NodeLogic

  def init(count) do
    {:ok, %{start: count, count: count}}
  end

  # Process tick event to count down
  def process(:tick, state, broadcast) do
    new_state =
      if state.count == 1 do
        broadcast.(:send)
        %{state | count: state.start}
      else
        %{state | count: state.count - 1}
      end

    {:ok, new_state}
  end
end

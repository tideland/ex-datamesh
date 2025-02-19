# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License

defmodule DatameshTest do
  use ExUnit.Case
  doctest DataMesh

  setup do
    # Start application befor tests
    {:ok, _} = Application.ensure_all_started(:datamesh)

    # Stop application when tests are done
    on_exit(fn ->
      Application.stop(:datamesh)
    end)

    :ok
  end

  test "basic node creation and data flow" do
    assert {:ok, broadcast_pid} = DataMesh.start_node(:broadcast, Broadcaster, [])
    assert is_pid(broadcast_pid)

    test_pid = self()
    test_data = "Hello DataMesh"

    assert {:ok, collector_pid} = DataMesh.start_node(:collect, Collector, test_pid)
    assert is_pid(collector_pid)

    assert :ok = DataMesh.create_link(:broadcast, :collect)

    DataMesh.send_data(:broadcast, test_data)
    DataMesh.send_data(:broadcast, :send)

    assert_receive {:received, [^test_data]}, 1000
  end

  test "node logic without init works with default state" do
    defmodule SimpleLogic do
      @behaviour NodeLogic

      def process(_data, state, _broadcast) do
        {:ok, state}
      end
    end

    assert {:ok, _pid} = DataMesh.start_node(:simple, SimpleLogic, [])
    assert :ok = DataMesh.send_data(:simple, "test")
  end

  test "invalid module (w/o process/3)" do
    defmodule InvalidLogic do
      def annything() do
        :ok
      end
    end

    assert {:error, {:invalid_logic_module, :invalid}} =
             DataMesh.start_node(:invalid, InvalidLogic, [])
  end
end

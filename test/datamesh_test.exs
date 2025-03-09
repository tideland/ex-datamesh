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

  test "basic node creation and data flow" do
    assert {:ok, broadcast_pid} = DataMesh.start_node(:broadcast, Broadcaster, [])
    assert is_pid(broadcast_pid)

    test_pid = self()
    test_data = "Hello DataMesh"

    assert {:ok, collector_pid} = DataMesh.start_node(:collect, Collector, test_pid)
    assert is_pid(collector_pid)

    assert :ok = DataMesh.create_link(:broadcast, :collect)

    DataMesh.send_data(:broadcast, test_data)
    
    assert {:ok, [^test_data]} = DataMesh.retrieve_data(:broadcast)
  end
  
  test "1:N:1 countdown broadcact and collection" do
    assert {:ok, broadcast_pid} = DataMesh.start_node(:broadcast, Broadcaster, [])
    assert is_pid(broadcast_pid)

    assert {:ok, countdowner_pid} = DataMesh.start_node(:counter, Countdowner, 10)
    assert is_pid(countdowner_pid)

    assert :ok = DataMesh.create_link(:broadcast, :counter)

    test_data = "test data"
    test_pid = self()

    # Start 10 collectors with test_pid
    for n <- 1..10 do
      node_name = String.to_atom("collect_#{n}")
      assert {:ok, collector_pid} = DataMesh.start_node(node_name, Collector, test_pid)
      assert is_pid(collector_pid)
      assert :ok = DataMesh.create_link(:broadcast, node_name)
    end

    # Send 10 test data items 
    for _i <- 1..10 do
      DataMesh.send_data(:broadcast, test_data) 
    end

    received_count = 0
    # Collect and verify data from all 10 collectors
    for _i <- 1..10 do
      receive do
        {:received, data} ->
          assert length(data) == 10
          ^received_count = received_count + 1
      after
        1000 -> flunk("Timeout waiting for collector data")
      end
    end

    assert received_count == 10
  end
end

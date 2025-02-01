defmodule DatameshTest do
  use ExUnit.Case
  doctest DataMesh

  setup do
    # Application als Ganzes starten
    {:ok, _} = Application.ensure_all_started(:datamesh)

    # Cleanup nach dem Test
    on_exit(fn ->
      Application.stop(:datamesh)
    end)

    :ok
  end

  # Ein einfacher Test mit einem Echo-Node
  test "basic node creation and data flow" do
    defmodule Echo do
      @behaviour DataMesh.NodeLogic

      def init(_opts), do: {:ok, %{}}

      def process(data, state, trigger) do
        # Echo sendet einfach die Daten unverändert weiter
        trigger.(data)
        {:ok, state}
      end
    end

    # Node erstellen
    assert {:ok, echo_pid} = DataMesh.start_node(:echo1, Echo, [])
    assert is_pid(echo_pid)

    # Test-Empfänger erstellen
    test_pid = self()

    defmodule Collector do
      @behaviour DataMesh.NodeLogic

      def init(test_pid), do: {:ok, %{test_pid: test_pid}}

      def process(data, state, _trigger) do
        send(state.test_pid, {:received, data})
        {:ok, state}
      end
    end

    # Collector-Node erstellen und mit Echo verbinden
    assert {:ok, collector_pid} = DataMesh.start_node(:collector1, Collector, test_pid)
    assert is_pid(collector_pid)

    assert :ok = DataMesh.create_link(:echo1, :collector1)

    # Daten an Echo senden
    test_data = "Hello DataMesh"
    DataMesh.trigger_data(:echo1, test_data)

    # Prüfen ob Daten ankommen
    assert_receive {:received, ^test_data}, 1000
  end
end

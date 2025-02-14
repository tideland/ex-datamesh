# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License

defmodule DataMesh.Impl.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      DataMesh.Impl.NodeSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Tell node supervisor to start a node with the given node logic.
  """
  def start_node(node_id, logic_module, options) do
    DataMesh.Impl.NodeSupervisor.start_node(node_id, logic_module, options)
  end
end

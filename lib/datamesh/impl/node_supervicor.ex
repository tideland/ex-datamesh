# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License
#
defmodule DataMesh.Impl.NodeSupervisor do
  @moduledoc false
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Start a node as child.
  """
  def start_node(node_id, logic_module, options) do
    child_spec = %{
      id: DataMesh.Impl.Node,
      start: {DataMesh.Impl.Node, :start_link, [node_id, logic_module, options]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end

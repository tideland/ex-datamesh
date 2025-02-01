defmodule DataMesh.Impl.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      DataMesh.Impl.NodeSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_node(node_id, logic_module, options) do
    DataMesh.Impl.NodeSupervisor.start_node(node_id, logic_module, options)
  end
end

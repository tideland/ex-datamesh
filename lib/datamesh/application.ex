defmodule DataMesh.Application do
  use Application
  
  @moduledoc """
  Application component for the DataMesh system.
  """
  
  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: DataMesh.NodeRegistry},
      DataMesh.Impl.Supervisor
    ]

    opts = [strategy: :one_for_one, name: DataMesh.RootSupervisor]
    Supervisor.start_link(children, opts)
  end
end
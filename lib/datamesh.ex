defmodule DataMesh do
  @moduledoc """
  Public API for the DataMesh system.
  """

  @doc """
  Starts a new data node with the given ID, logic module and options.
  """
  def start_node(node_id, logic_module, options \\ []) do
    DataMesh.Impl.Supervisor.start_node(node_id, logic_module, options)
  end

  @doc """
  Creates a link between two nodes.
  """
  def create_link(from_node, to_node) do
    GenServer.call(via_tuple(from_node), {:create_link, to_node})
  end

  @doc """
  Triggers data processing in a specific node.
  """
  def trigger_data(node_id, data) do
    GenServer.cast(via_tuple(node_id), {:process_data, data})
  end

  @doc """
  Retrieves information about a specific node.
  """
  def get_node_info(node_id) do
    GenServer.call(via_tuple(node_id), :get_info)
  end

  # Helper function used internally
  defp via_tuple(node_id), do: {:via, Registry, {DataMesh.NodeRegistry, node_id}}
end

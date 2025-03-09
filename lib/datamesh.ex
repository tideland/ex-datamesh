# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License

defmodule DataMesh do
  @moduledoc """
  DataMesh is an Elixir library providing a framework for data
  processing in distributed systems. It allows you to create a
  network of processing nodes where each node can receive, process,
  and forward data to connected nodes.
  """

  @doc """
  Starts a new data node with the given ID, logic module and options.
  """
  def start_node(node_id, logic_module, options \\ []) do
    DataMesh.Impl.Supervisor.start_node(node_id, logic_module, options)
  end

  @doc """
  Start a list of nodes, each defined as a tuple with node ID, logic
  module and options.
  """
  def start_nodes(nodes) when is_list(nodes) do
    Enum.reduce_while(nodes, :ok, fn {id, logic, args}, _acc ->
      case start_node(id, logic, args) do
        {:ok, _pid} -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  @doc """
  Creates a link between two nodes.
  """
  def create_link(from_node, to_node) do
    GenServer.call(via_tuple(from_node), {:create_link, to_node})
  end

  @doc """
  Sends data processing in a specific node.
  """
  def send_data(node_id, data) do
    GenServer.cast(via_tuple(node_id), {:process_data, data})
  end

  @doc """
  Retrieves data from a node.
  """
  def retrieve_data(node_id, key) do
    GenServer.call(via_tuple(node_id), {:retrieve_data, key})
  end

  def retrieve_data(node_id) do
    GenServer.call(via_tuple(node_id), :retrieve_data)
  end

  @doc """
  Retrieves information about a specific node.
  """
  def get_node_info(node_id) do
    GenServer.call(via_tuple(node_id), :get_info)
  end

  ##
  # PRIVATE FUNCTIONS
  ##

  # Create a tuple helping to retrieve node information from
  # the registry.
  defp via_tuple(node_id), do: {:via, Registry, {DataMesh.NodeRegistry, node_id}}
end

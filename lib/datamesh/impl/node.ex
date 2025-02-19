defmodule DataMesh.Impl.Node do
  use GenServer
  require Logger

  @moduledoc false

  def start_link(node_id, logic_module, options) do
    unless function_exported?(logic_module, :process, 3) do
      # Needs at least the process/3 function
      {:error, {:invalid_logic_module, node_id}}
    else
      GenServer.start_link(__MODULE__, {node_id, logic_module, options},
        name: {:via, Registry, {DataMesh.NodeRegistry, node_id}}
      )
    end
  end

  #
  # GenServer callbacks
  #

  @impl true
  def init({node_id, logic_module, options}) do
    initial_state = %{
      node_id: node_id,
      logic_module: logic_module,
      options: options,
      links: [],
      logic_state: nil
    }

    state =
      if function_exported?(logic_module, :init, 1) do
        # Call the init/1 if it's implemented
        case logic_module.init(options) do
          {:ok, logic_state} -> %{initial_state | logic_state: logic_state}
          _ -> initial_state
        end
      else
        initial_state
      end

    {:ok, state}
  end

  @impl true
  def handle_cast({:process_data, data}, state) do
    # Erstelle die Trigger-Funktion für diese Node
    trigger = fn output_data ->
      Enum.each(state.links, fn link_id ->
        DataMesh.send_data(link_id, output_data)
      end)

      :ok
    end

    case apply(state.logic_module, :process, [data, state.logic_state, trigger]) do
      {:ok, new_logic_state} ->
        {:noreply, %{state | logic_state: new_logic_state}}

      {:error, reason} ->
        Logger.error("Processing error in node #{state.node_id}: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:create_link, to_node}, _from, state) do
    updated_links = [to_node | state.links]
    {:reply, :ok, %{state | links: updated_links}}
  end

  def handle_call(:get_info, _from, state) do
    info = %{
      node_id: state.node_id,
      logic_module: state.logic_module,
      options: state.options,
      links: state.links
    }

    {:reply, info, state}
  end
end

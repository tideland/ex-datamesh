# DataMesh

DataMesh is an Elixir library providing a framework for data processing
in distributed systems. It allows you to create a network of processing
nodes where each node can receive, process, and forward data to connected
nodes.

## Ideas and Principles

DataMesh is built around the concept of small, focused processing units
(DataNodes) that can be freely connected to form sophisticated data
processing networks. This approach follows several key principles:

### Separation of Concerns

Each DataNode implements a specific processing logic encapsulated in
its NodeLogic. This separation allows you to build complex processing
workflows from simple, reusable components. The processing logic is
completely separated from the mechanics of data distribution and node
management.

### Flexible Data Flow

DataMesh supports both broadcast-style communication to all connected
nodes and targeted sending to specific nodes. This flexibility allows
for implementing various patterns like pipelines, fan-out, aggregation,
or complex routing scenarios. Nodes can be connected and disconnected
at runtime, enabling dynamic reconfiguration of the processing network.

### State Management

Each DataNode maintains its own state, initialized and updated through
its NodeLogic. This local state management allows nodes to accumulate
data, maintain configuration, or keep processing context without affecting
other nodes. The state is isolated and can only be modified through the
node's processing logic.

### Location Transparency

Nodes are identified by arbitrary terms and managed through a central
registry. This abstraction allows for flexible deployment patterns and
makes it possible to distribute nodes across different processes or even
machines (within an Erlang cluster) without changing the processing
logic.

### Simple Yet Powerful

While the core concepts are straightforward - nodes, connections, and
data flow - they can be combined to create sophisticated processing
networks. The library focuses on providing the essential building
blocks while leaving the implementation of specific processing logic
to the application layer.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `datamesh` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:datamesh, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/datamesh>.

## Usage

### Starting Nodes and Creating Connections

```elixir
# Start nodes
DataMesh.start_node(:source, MyApp.SourceLogic, [])
DataMesh.start_node(:filter, MyApp.FilterLogic, [threshold: 10])
DataMesh.start_node(:sink, MyApp.SinkLogic, [])

# Connect nodes
DataMesh.connect(:source, :filter)
DataMesh.connect(:filter, :sink)

# Send data
DataMesh.trigger_data(:source, sensor_data)
```

### Libray NodeLogic Components

- **TBD**

### Implementing Custom NodeLogic

```elixir
defmodule MyApp.FilterLogic do
  @behaviour NodeLogic

  def init(args) do
    threshold = Keyword.get(args, :threshold, 0)
    {:ok, %{threshold: threshold}}
  end

  def process(data, state, broadcast) do
    if data > state.threshold do
      broadcast.(data)
    end
    {:ok, state}
  end
end
```

Your NodeLogic implementation can:

- Use the broadcast function to send data to all connected nodes
- Use `DataMesh.send_data/2` to send data to specific nodes
- Maintain state between processing calls

## Node Identification

Nodes can be identified by any term, not just atoms:

```elixir
DataMesh.start_node(:atom_id, MyLogic, [])
DataMesh.start_node("string_id", MyLogic, [])
DataMesh.start_node({:complex, "id"}, MyLogic, [])
```

## Organization

When using DataMesh in your application:

1. Put your custom NodeLogic implementations in your application structure:

```
your_app/
  lib/
    your_app/
      node_logics/
        source_logic.ex
        filter_logic.ex
        sink_logic.ex
```

2. Start your nodes either in your application startup or where
   needed in your business logic.

## License

This project is licensed under the BSD 3-Clause License - see the
LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

# Copyright (c) 2025 Tideland - Frank Mueller
# Licensed under the BSD 3-Clause License

defmodule DataMesh.NodeLogic do
  @moduledoc """
  Behaviour definition for node logic implementations.
  """

  @type broadcast_fn :: (any -> :ok)
  @type state :: any

  @doc """
  Optional initialization of the node logic.
  """
  @callback init(opts :: any) :: {:ok, state} | {:error, any}

  @doc """
  Process received data in the node logic. Any data can be
  broadcasted to the connected nodes by using the broadcast function.
  """
  @callback process(data :: any, state :: state, broadcast :: broadcast_fn) ::
              {:ok, state} | {:error, any}

  @optional_callbacks [
    init: 1
  ]
end

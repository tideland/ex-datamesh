defmodule DataMesh.NodeLogic do
  @moduledoc """
  Behaviour definition for node logic implementations.
  """

  @type trigger_fn :: (any -> :ok)
  @type state :: any

  @callback init(opts :: any) :: {:ok, state} | {:error, any}
  @callback process(data :: any, state :: state, trigger :: trigger_fn) ::
              {:ok, state} | {:error, any}

  @optional_callbacks [
    init: 1
  ]
end
defmodule GenSpoxy.Partitionable do
  @moduledoc """
  since `GenServer` based module, process its own mailbox messages in serial manner,
  it's subject to have a long queuing time in case the queue becomes big.

  In order to scale such modules, we introduce the `GenSpoxy.Partitionable` behaviour,
  it will be implemented by modules that require and suit a paritioning logic
  """

  defmacro __using__(_opts) do
    quote do
      @behaviour Spoxy.Partitionable.Behaviour

      def partition_server(partition) do
        {:global, "#{__MODULE__}-#{partition}"}
      end

      defoverridable partition_server: 1
    end
  end
end

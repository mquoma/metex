defmodule Vertex do
  defstruct node: nil, edges: []
end

defmodule Stack do
  use GenServer

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def add_node(pid, node) do
    GenServer.cast(pid, {:add_node, node})
  end

  def get_nodes(pid) do
    GenServer.call(pid, :get_nodes)
  end

  # Server (callbacks)

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:get_nodes, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:add_edge, n, m}, state) do
    {:noreply, [%Vertex{node: n, edges: [{n, m}]} | state]}
  end

  @impl true
  def handle_cast({:add_node, node}, state) do
    {:noreply, [%Vertex{node: node} | state]}
  end
end

#
# # Start the server
# {:ok, pid} = GenServer.start_link(Stack, [:hello])
#
# # This is the client
# GenServer.call(pid, :pop)
# #=> :hello
#
# GenServer.cast(pid, {:push, :world})
# #=> :ok
#
# GenServer.call(pid, :pop)
# #=> :world

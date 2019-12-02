defmodule CrestronCip.Client do
  @timeout 500

  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init([host, port]) do
    with sock <- Socket.TCP.connect!(host, port, packet: :raw, timeout: 5_000),
      <<0x0f, 0x00, 0x01, 0x02>> <- Socket.Stream.recv!(sock, timeout: 5_000) do
        send(self(), :read_sock)
        {:ok, %{socket: sock, host: host, port: port}}
    end
  end

  def handle_call({:sign_on, ip_id}, _from, %{socket: sock, host: host} = state) do
    signon_msg = <<0x0a, 0x00, 0x23, 0x00, ip_id, 0xa3, 0x42, 0x40, 0x02, 0xff, 0xff, 0xf1, 0x01>> <> host
    with {:reply, <<0x02, 0x00, 0x04, 0x00, 0x00, 0x00, 0x1f>>, state} <- handle_call({:send_msg, signon_msg}, self(), state) do
      {:reply, :ok, state}
    else
      any ->
        Logger.error(inspect(any))
        {:reply, :error, state}
    end
  end

  def handle_call({:send_msg, msg}, _from, %{socket: sock} = state) do
    Socket.Stream.send!(sock, msg)
    resp = case Socket.Stream.recv(sock, timeout: @timeout) do
      {:error, :timeout} -> nil
      {:ok, resp} -> resp
    end

    {:reply, resp, state}
  end

  @impl true
  def handle_cast({:send_msg, msg}, %{socket: sock} = state) do
    Socket.Stream.send!(sock, msg)
    Logger.debug "ok"
    {:noreply, state}
  end

  @impl true
  def handle_info(:read_sock, %{socket: sock} = state) do
    case Socket.Stream.recv(sock, timeout: @timeout) do
      {:error, :timeout} -> nil
      {:ok, <<0x0d, 0x00, 0x02, 0x00, 0x00>>} ->
        # Ping
        pong()
      {:ok, resp} ->
        decoded = CrestronCip.Decoder.decode(resp)
        Logger.warn(inspect(resp) <> " decodes to " <> inspect(decoded))
    end

    send(self(), :read_sock)
    {:noreply, state}
  end


  defp pong(), do: GenServer.cast(self(), {:send_msg, <<0x0e, 0x00, 0x02, 0x00, 0x00>>})
  def sign_on(pid, ip_id), do: GenServer.call(pid, {:sign_on, ip_id})
end

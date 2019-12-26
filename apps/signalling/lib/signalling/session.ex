defmodule Signalling.Session do
  use GenServer
  require Logger
  import Exexec, only: [run_link: 2]

  @response_waiting_time 30_000
  @ping_waiting_time 60_000

  def start(session_id, intercom_serial_key, audio_input, audio_output) do
    GenServer.start(__MODULE__, [session_id, intercom_serial_key, audio_input, audio_output], name: via_tuple(session_id))
  end

  defp via_tuple(session_id), do: {:via, Registry, {Registry.CallSession, session_id}}

  def session_exists?(session_id) do
    case Registry.lookup(Registry.CallSession, session_id) do
      []  -> false
      [{_pid, _}] -> true
    end
  end

  def session_info(session_id) do
    GenServer.call(via_tuple(session_id), :session_info)
  end

  def respond(session_id, caller_id) do
    GenServer.call(via_tuple(session_id), {:respond, caller_id})
  end

  def ping(session_id, caller_id) do
    case Registry.lookup(Registry.CallSession, session_id) do
      [{pid, _}] -> send(pid, {:ping, caller_id})
    end
  end

  def hang(session_id, caller_id) do
    case Registry.lookup(Registry.CallSession, session_id) do
      [{pid, _}] -> send(pid, {:hang, caller_id})
    end
  end

  def caller_owns_session?(session_id, caller_id), do: GenServer.call(via_tuple(session_id), {:caller_check, caller_id})

  def init([session_id, intercom_serial_key, audio_input, audio_output]) do
    Process.flag(:trap_exit, true)
    Logger.info("Call session##{session_id} created...")
    initial_state = %{
        session_id: session_id,
        audio_input: audio_input,
        audio_output: audio_output,
        intercom_serial_key: intercom_serial_key,
        caller_id: nil,
        timer_ref: Process.send_after(self(), :end_process, @response_waiting_time),
        audio_relay: spawn_audio_relay(audio_input, audio_output)
    }

    {:ok, initial_state}
  end

  @doc false
  def handle_call({:respond, caller_id}, _from, %{caller_id: nil, audio_input: audio_input, timer_ref: timer_ref, session_id: session_id} = state) do
    Process.cancel_timer(timer_ref)
    Logger.info("Call session##{session_id} received response from ##{caller_id}")
    updated_state = Map.put(state, :caller_id, caller_id)
    response = %{audio_port: audio_input}
    {:reply, {:ok, response}, updated_state}
  end

  @doc false
  def handle_call({:respond, _caller_id}, _from, %{session_id: session_id, caller_id: caller_id} = state) do
    Logger.warn("Call session##{session_id} received late response from ##{caller_id}")
    {:reply, {:ok, :session_busy}, state}
  end

  @doc false
  def handle_call({:caller_check, caller_id}, _from, %{caller_id: session_caller_id} = state) do
    {:reply, caller_id == session_caller_id, state}
  end

  @doc false
  def handle_call(:session_info, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:ping, caller_id}, %{session_id: session_id, caller_id: caller_id} = state) do
    Logger.info("Call session##{session_id} recieved ping from ##{caller_id}")
    updated_state = case state do
        %{timer_ref: nil} ->
            %{ state | timer_ref: Process.send_after(self(), :end_process, @ping_waiting_time) }
        %{timer_ref: timer_ref} ->
            Process.cancel_timer(timer_ref)
            %{ state | timer_ref: Process.send_after(self(), :end_process, @ping_waiting_time) }
    end

    {:noreply, updated_state}
  end

  def handle_info({:hang, caller_id}, %{session_id: session_id, caller_id: caller_id} = state) do
    Logger.info("Call session##{session_id} ended due to client##{caller_id} hanging...")
    {:stop, :normal, state}
  end

  def handle_info(:end_process, %{session_id: session_id} = state) do
    Logger.warn("Call session##{session_id} ended due to lack of response")
    {:stop, :normal, state}
  end

  def handle_info({:stdout, os_pid, stdout}, %{audio_relay: %{os_pid: os_pid}} = state) do
    Logger.info("Audio relay stdout: #{inspect(stdout)}")
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, {:exit_status, exit_status}}, %{audio_relay: %{pid: pid}} = state) do
    Logger.error("Audio relay process crashed for unknown reason. Terminating... EXIT_STATUS: #{inspect(exit_status)}, STATE: #{inspect(state)}")
    {:stop, :normal, state}
  end

  def handle_info({:EXIT, pid, :normal}, %{audio_relay: %{pid: pid}} = state) do
    Logger.error("Audio relay process got normal exit for unknown reason. Terminating... STATE: #{inspect(state)}")
    {:stop, :normal, state}
  end

  def handle_info(msg, state) do
      Logger.warn("Unhandled info for call session... MSG: #{inspect(msg)}, STATE: #{inspect(state)}")
      {:noreply, state}
  end

  def spawn_audio_relay(audio_input, audio_output) do
    host = Application.get_env(:signalling, :host)
    script_exec = "gst-launch-1.0 udpsrc port=#{audio_input} ! tcpserversink host=#{host} port=#{audio_output}"
    {:ok, pid, os_pid} = run_link(script_exec, stdout: true)
    %{pid: pid, os_pid: os_pid}
  end
end
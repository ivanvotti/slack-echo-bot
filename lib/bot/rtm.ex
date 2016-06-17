defmodule Bot.RTM do
  @moduledoc """
  Minimal Slack Real Time Messaging (RTM) API interface.
  It allows the echo bot to work through a websocket connection.
  """
  defmacro __using__(_) do
    quote do
      @behaviour :websocket_client_handler
      @rtm_url "https://slack.com/api/rtm.start?token="

      def start_link(token) do
        case fetch_rtm(token) do
          {:ok, rtm} ->
            state = %{rtm: rtm, token: token}

            rtm.url
            |> String.to_char_list()
            |> :websocket_client.start_link(__MODULE__, state)
          {:error, error} ->
            {:error, error}
        end
      end

      defp fetch_rtm(token) do
        with {:ok, response} <- HTTPoison.get(@rtm_url <> token),
             {:ok, rtm_data} <- decode_rtm_response(response),
             do: {:ok, rtm_data}
      end

      defp decode_rtm_response(response) do
        case JSX.decode!(response.body, [{:labels, :atom}]) do
          %{error: reason, ok: false} ->
            {:error, reason}
          rtm_data ->
            {:ok, rtm_data}
        end
      end

      def init(state, socket) do
        state = Map.put(state, :socket, socket)
        {:ok, state}
      end

      def websocket_handle({:ping, data}, _conn, state) do
        {:reply, {:pong, data}, state}
      end

      def websocket_handle({:text, message}, _conn, state) do
        message =
          message
          |> :binary.split(<<0>>)
          |> List.first()
          |> JSX.decode!([{:labels, :atom}])

        if message[:type] == "message" and Map.has_key?(message, :text) do
          handle_message(message, state)
        else
          {:ok, state}
        end
      end

      def websocket_info(_message, _conn, state), do: {:ok, state}

      def websocket_terminate(_reason, _conn, state), do: {:error, state}

      def send_message(text, channel, %{socket: socket}) do
        %{
          type: "message",
          text: text,
          channel: channel
        }
          |> JSX.encode!()
          |> send_string_to_socket(socket)
      end

      defp send_string_to_socket(string, socket) do
        :websocket_client.send({:text, string}, socket)
      end

      def handle_message(_message, state), do: {:ok, state}

      defoverridable [handle_message: 2]
    end
  end
end

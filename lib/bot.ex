defmodule Bot do
  use Bot.RTM

  def handle_message(message, state) do
    bot_id = state.rtm.self.id

    if message_to_bot?(message, bot_id) and !self_message?(message, bot_id) do
      anwser = "I've got a message: #{message.text}"
      send_message(anwser, message.channel, state)
    end

    {:ok, state}
  end

  defp self_message?(message, bot_id),
    do: message[:user] == bot_id

  defp message_to_bot?(message, bot_id),
    do: String.contains?(message.text, "<@#{bot_id}>")
end

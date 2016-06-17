defmodule Bot.CLI do
  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  defp parse_args(args) do
    case OptionParser.parse(args, strict: [token: :string]) do
      {[token: token], _remaining, _invalid} ->
        token
      _ ->
        :help
    end
  end

  defp process(:help) do
    IO.puts("usage: bot --token <token>")
    System.halt(0)
  end
  defp process(token) do
    connect_to_rtm(token)
    :timer.sleep(:infinity)
  end

  defp connect_to_rtm(token) do
    case Bot.start_link(token) do
      {:ok, _} ->
        IO.puts("Connected")
      {:error, error} ->
        IO.puts("There was an error: #{error}")
        System.halt(0)
    end
  end
end

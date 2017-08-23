defmodule Client do
  @moduledoc """
  Documentation for Client.
  """

  @doc """
  ## Examples

      iex> {:ok, body} = Client.random_event()
  """
  def random_event do
    url = Application.get_env(:client, :server_url) || exit "Missing :server_url config"

    id = Tapper.start(name: "client requesting", sample: true)
    headers = trace_headers(id)

    resp = HTTPoison.get(url <> "/random_event", headers)

    result = case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> 
        Tapper.update_span(id, :cr)
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: code}} -> 
        Tapper.update_span(id, :cr)
        {:error, "Status #{code}"}
      e -> 
        IO.puts(:standard_error, "Error #{inspect e}")
        Tapper.update_span(id, :error)
        {:error, "Request failed"}
    end

    Tapper.finish(id)

    result
  end

  def trace_headers(id) do
    Tapper.Plug.HeaderPropagation.encode(id)
  end
end

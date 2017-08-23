defmodule Server.Router do
  use Plug.Router

  plug :match
  plug Tapper.Plug.Trace

  get "/random_event" do
    # NB server has 'joined' incoming span via `Tapper.Plug` handling of B3 headers

    tapper_id = 
      conn
        |> Tapper.Plug.fetch()
        |> Tapper.start_span(name: "github-events", annotations: [
          :cs, 
          Tapper.server_address(%Tapper.Endpoint{service_name: "github", hostname: "api.github.com"})
        ])

    resp = HTTPoison.get("https://api.github.com/repos/Financial-Times/tapper/events", [{"accept", "application/json"}])
    result = case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Tapper.update_span(tapper_id, [:cr, Tapper.http_response_size(String.length(body))])
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: code}} ->
        Tapper.update_span(tapper_id, [:cr, Tapper.http_status_code(code), :error])
        {:error, "Github returned status #{code}"}
      {:error, error} ->
        Tapper.update_span(tapper_id, [:cr, :error])
        {:error, "Github HTTP protocol failure #{inspect error}"}
      end

    Tapper.finish_span(tapper_id)

    case result do
      {:ok, body} ->
        random_event = 
          body 
          |> Poison.decode!()
          |> Enum.take_random(1)

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, Poison.encode!(random_event))
      
      {:error, message} ->
        send_resp(conn, 500, message)
    end
    
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  plug :dispatch
  
end

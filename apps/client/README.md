# Client

Client to call a running server with tracing; ensure server is started then:

```
iex -S mix
iex> Client.random_event
{:ok, "[{...}]"}
```

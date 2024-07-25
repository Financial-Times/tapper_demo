# !!! This repository would be changed to private on 30th of September !!!

# Tapper Demo

A simple client and server pair (in an umbrella app), demonstrating:

   * Tapper API use for creating spans and annotations.
   * `Tapper.Plug` use in server.
   * B3 Encoding of trace headers for clients.

# Usage

1. Start a local Zipkin server using the instructions in the Open Zipkin repo: https://github.com/openzipkin/zipkin/#quick-start

2. In the top-level directory: 
```
mix deps.get && mix compile
```

3. Start the server app:

```
cd apps/server
iex -S mix
```

4. In another shell, start the client app:

```
cd apps/client
iex -S mix
```

5. Run a request on the client:
```
Client.random_event()
```

6. Check the Zipkin server for traces by going to http://localhost:9411/ and searching for traces using the "Find Traces" button.

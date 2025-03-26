defmodule HttpServerTest do

    use ExUnit.Case

    alias Servy.HttpServer
    alias Servy.HttpClient

    test "accepts a request on a socket and sends back a response" do
        # spawn(fn -> Servy.HttpServer.start(4000) end)
        spawn(HttpServer, :start, [4000])

        request = """
        GET /wildthings HTTP/1.1\r
        Host: example.com\r
        User-Agent: ExampleBrowser/1.0\r
        Accept: */*\r
        \r
        """

        response = HttpClient.send_request(request)

        expected_response = """
        HTTP/1.1 200 OK\r
        Content-Type: text/html\r
        Content-Length: 20\r
        \r
        Bears, Lions, Tigers
        """

      assert remove_whitespace(response) == remove_whitespace(expected_response)
    end
    
    defp remove_whitespace(text) do
        String.replace(text, ~r{\s}, "")
    end
end
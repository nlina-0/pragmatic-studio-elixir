defmodule HttpServerTest do

    use ExUnit.Case

    alias Servy.HttpServer
    # alias Servy.HttpClient

    # test "accepts a request on a socket and sends back a response" do
    #     # spawn(fn -> Servy.HttpServer.start(4000) end)
    #     spawn(HttpServer, :start, [4000])

    #     request = """
    #     GET /wildthings HTTP/1.1\r
    #     Host: example.com\r
    #     User-Agent: ExampleBrowser/1.0\r
    #     Accept: */*\r
    #     \r
    #     """

    #     response = HttpClient.send_request(request)

    #     expected_response = """
    #     HTTP/1.1 200 OK\r
    #     Content-Type: text/html\r
    #     Content-Length: 20\r
    #     \r
    #     Bears, Lions, Tigers
    #     """

    #   assert remove_whitespace(response) == remove_whitespace(expected_response)
    # end

    # defp remove_whitespace(text) do
    #     String.replace(text, ~r{\s}, "")
    # end

    test "accepts a request on a socket and sends back a response" do
        spawn(HttpServer, :start, [4000])

        {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")

        assert response.status_code == 200
        assert response.body == "Bears, Lions, Tigers"
    end

    # test "spawn 5 requests concurrently" do
    #     spawn(HttpServer, :start, [4000])

    #     parent = self()

    #     max_req = 5

    #     # spawning the client process
    #     for _ <- 1..max_req do
    #         # send the request
    #         {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")

    #         # send the response back to the parent
    #         spawn(fn -> send(parent, {:ok, response}) end)
    #     end

    #     # await all messages from spawned process
    #     for _ <- 1..max_req do
    #         receive do
    #             {:ok, response} -> 
    #                 assert response.status_code == 200
    #                 assert response.body == "Bears, Lions, Tigers"
    #         end
    #     end
    # end

    test "accepts multiple requests concurrently on a socket and sends back a response" do
        spawn(HttpServer, :start, [4000])

        # url = "http://localhost:4000/wildthings"

        urls = [
            "http://localhost:4000/wildthings",
            "http://localhost:4000/bears",
            "http://localhost:4000/bears/1",
            "http://localhost:4000/wildlife",
            "http://localhost:4000/api/bears"
          ]

        # 1..5
        urls
        |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
        |> Enum.map(&Task.await/1)
        |> Enum.map(&asser_successful_response/1)
    end

    defp asser_successful_response({:ok, response}) do
        assert response.status_code == 200
        # assert response.body == "Bears, Lions, Tigers"
    end
    
end

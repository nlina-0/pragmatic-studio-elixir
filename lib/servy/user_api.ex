defmodule Servy.UserApi do
    
    @doc """
    get the city for a given user id or handle any errors like so:
    """

    def query(id) when is_integer(id), do: query(Integer.to_string(id))

    # query the api request
    def query(id) do
        # obtain the url with the id
        api_url(id)
        # gets json response from url
        |> HTTPoison.get
        |> handle_response
    end

    # api defined
    def api_url(id) do
        "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
    end

    # handles response by pattern matching on map
    defp handle_response({:ok, %{status_code: 200, body: body}}) do
        city = 
            Poison.Parser.parse!(body, %{})
            |> get_in(["address", "city"])
        
        {:ok, city}
    end

    # if its anything other than status 200
    defp handle_response({:ok, %{status_code: _status, body: body}}) do
        message = 
            Poison.Parser.parse!(body, %{})
            |> get_in(["message"])

        {:error, message}
    end

    defp handle_response({:error, %{reason: reason}}) do
        {:error, reason}
    end
end


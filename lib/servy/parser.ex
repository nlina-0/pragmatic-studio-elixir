defmodule Servy.Parser do

    alias Servy.Conv

    def parse([request]), do: parse(request)

    # def parse(request) when is_list(request) do
    #     request = Enum.join(request, "") # Convert list to a single string
    #     IO.inspect(parse(request), label: "parse fn")
    # end

    # def parse(request) do
    #     # IO.inspect(request, label: "debugging")
    #     # params_string is the content
    #     [top, params_string] = String.split(request, "\r\n\r\n")
        
    #     [request_line | header_lines] = String.split(top, "\r\n")
        
    #     [method, path, _] =  String.split(request_line, " ")
        
    #     headers = parse_headers(header_lines, %{})
        
    #     params = parse_params(headers["Content-Type"], params_string)
        
    #     %Conv{  
    #         method: method, 
    #         path: path,
    #         params: params,
    #         headers: headers
    #     }
    # end

    def parse(request) do
        parts = String.split(request, "\r\n\r\n", parts: 2) 
      
        case parts do
          [top, params_string] -> 
            [request_line | header_lines] = String.split(top, "\r\n")
            [method, path, _] = String.split(request_line, " ")
            headers = parse_headers(header_lines, %{})
            params = parse_params(headers["Content-Type"], params_string)
      
            %Conv{ 
              method: method, 
              path: path,
              params: params,
              headers: headers
            }
      
          [top] ->  # Case when there is no "\r\n\r\n" (GET request with no body)
            [request_line | header_lines] = String.split(top, "\r\n")
            [method, path, _] = String.split(request_line, " ")
            headers = parse_headers(header_lines, %{})
      
            %Conv{ 
              method: method, 
              path: path,
              params: %{},  # No body
              headers: headers
            }
        end
      end

    def parse_headers([head | tail], headers) do
        [key, value] = String.split(head, ": ")
        headers = Map.put(headers, key, value)
        parse_headers(tail, headers)
    end

    # tail call optimisation
    def parse_headers([], headers), do: headers

    @doc """
    Parses the given param string of the form `key1=value&key2=value2` into a map with corresponding keys and values.

    ## Examples
        iex> params_string = "name=Baloo&type=Brown"
        iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
        %{"name" => "Baloo", "type" => "Brown"}
        iex> Servy.Parser.parse_params("multipart/form-data", params_string)
        %{}
    """
    def parse_params("application/x-www-form-urlencoded", params_string) do
        params_string |> String.trim |> URI.decode_query
    end

    def parse_params("application/json", params_string) do
        Poison.Parser.parse!(params_string, %{})
    end

    def parse_params(_, _), do: %{}
end
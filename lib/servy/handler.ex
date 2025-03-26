defmodule Servy.Handler do

    @moduledoc "Handles HTTP requests."

    alias Servy.Conv
    alias Servy.BearController
    alias Servy.VideoCam

    # Module attribute
    @pages_path Path.expand("../../pages", __DIR__)

    import Servy.Plugin, only: [rewrite_path: 1, log: 1, track: 1]
    import Servy.Parser, only: [parse: 1]
    import Servy.FileHandler, only: [handle_file: 2]

    # Why does the alias work? Do  i not need to import it?
    # import Servy.BearController, only: [index: 1, show: 2, create: 2]

    @doc "Transforms the request into a response."
    def handle(request) do
        request
        |> parse
        |> rewrite_path
        |> log
        |> route
        |> track
        |> put_content_length
        |> format_response
        
    end

    def route(%Conv{ method: "GET", path: "/snapshots" } = conv) do
        parent = self()
        
        spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-1")}) end)
        spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-2")}) end)
        spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-3")}) end)
      
        snapshot1 = receive do {:result, filename} -> filename end
        snapshot2 = receive do {:result, filename} -> filename end
        snapshot3 = receive do {:result, filename} -> filename end

        snapshots = [snapshot1, snapshot2, snapshot3]
      
        %{ conv | status: 200, resp_body: inspect snapshots}
    end

    # function clauses
    def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
        %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
    end

    # Bears route

    def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
        Servy.Api.BearController.index(conv)
    end
    
    def route(%Conv{ method: "GET", path: "/bears" } = conv) do
        BearController.index(conv)
    end

    
    def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
        params = Map.put(conv.params, "id", id)
        BearController.show(conv, params)
    end

    # name=Baloo&type=Brown
    def route(%Conv{ method: "POST", path: "/api/bears"} = conv) do
        Servy.Api.BearController.create(conv, conv.params)
    end

    def route(%Conv{ method: "POST", path: "/bears"} = conv) do
        BearController.create(conv, conv.params)
    end
    
    # delete route
    def route(%Conv{ method: "DELETE", path: "/bears/" <> _id } = conv) do
        BearController.delete(conv, conv.params)
    end
    
    # FORM: responds by serving the form
    # def route(%{ method: "GET", path: "/bears/new" } = conv) do
    #     Path.expand("../../pages", __DIR__)
    #     |> Path.join("form.html")
    #     |> File.read
    #     |> handle_file(conv)
    # end 

    # def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    #     file = Path.join(@pages_path, "form.html")

    #     case File.read(file) do
    #         {:ok, content} -> 
    #             %{ conv | status: 200, resp_body: content }
            
    #         {:error, :enoent} -> 
    #             %{ conv| status: 404, resp_body: "File not found!"}
                
    #         {:error, reason} -> 
    #             %{ conv| status: 500, resp_body: "File error: #{reason}"}

    #     end
    # end

    # ABOUT
    def route(%Conv{ method: "GET", path: "/about" } = conv) do
        # gets the absolute path
        @pages_path
        |> Path.join("about.html")
        |> File.read
        |> handle_file(conv)
    end

    def route(%Conv{ method: "GET", path: "/pages/" <> file } = conv) do
        @pages_path
        |> Path.join(file <> ".html")
        |> File.read
        |> handle_file(conv)
    end

    # catch all route
    def route(%Conv{ path: path } = conv) do
        %{ conv | status: 404, resp_body: "No #{path} here!" }
    end

    def put_content_length(conv) do
        headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
        %{ conv | resp_headers: headers }
    end
    
    # 19. Rendering JSON exercise: imagine you have an arbitrary number of response headers and you want to dynamically generate a multi-line string of all the response header keys and values.
    def format_response(%Conv{} = conv) do
        """
        HTTP/1.1 #{Conv.full_status(conv)}\r
        Content-Type: #{conv.resp_headers["Content-Type"]}\r
        Content-Length: #{conv.resp_headers["Content-Length"]}\r
        \r
        #{conv.resp_body}
        """
    end
end
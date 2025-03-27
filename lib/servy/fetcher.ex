defmodule Servy.Fetcher do

    def async(fun) do
        parent = self()
        spawn(fn -> send(parent, {self(), :result, fun.()}) end)
    end

    def get_result(pid) do
        # the ^ operator ensures that the existing value to variable is being called and not binding the variable to a new value.
        receive do 
            {^pid, :result, value} -> value 
        after 2000 ->
            raise "Timed out!"
        end
    end
end
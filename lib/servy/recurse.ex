defmodule Recurse do

    # reduce algorithm
    def sum([head | tail], total) do
      # IO.puts "Head: #{head} Tail: #{inspect(tail)}"
      sum(tail, total + head)
    end
  
    def sum([], total), do: total

    # def triple([head|tail]) do
    #     [head*3 | triple(tail)]
    # end

    # def triple([]), do: []

    def triple(list) do
        triple(list, [])
    end

    # current_list is an accumulator 
    defp triple([head|tail], current_list) do
        triple(tail, [head*3 | current_list])
    end

    defp triple([], current_list) do
        current_list |> Enum.reverse()
    end

    # Recusrion to traverse the list, doubling each element and returning a new list.
    # The process of taking a list and mapping over it is known as a map algorithm.
    def double_each([head | tail]) do
        [head * 2 | double_each(tail)]
      end
    
      def double_each([]) do
        []
      end
  end
  
  # IO.puts Recurse.sum([1, 2, 3, 4, 5], 0)

  # IO.inspect Recurse.triple([1, 2, 3, 4, 5])
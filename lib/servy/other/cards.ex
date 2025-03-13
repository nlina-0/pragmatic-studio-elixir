defmodule Servy.DeckOfCards do
    def cards(ranks, suits) do
        for ranks <- ranks, suits <- suits, do: {ranks, suits}
    end
end

ranks =
  [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" ]

suits =
  [ "♣", "♦", "♥", "♠" ]

# deck = for ranks <- ranks, suits <- suits, do: {ranks, suits}

deck = Servy.DeckOfCards.cards(ranks, suits)

#draw = Enum.take_random(deck, 13)
#IO.inspect draw

#shuffle_draw = deck |> Enum.shuffle |> Enum.take(13)
#IO.inspect shuffle_draw

# deal 4 hands of 13 cards
four_hands = deck |> Enum.shuffle |> Enum.chunk_every(13)
IO.inspect four_hands

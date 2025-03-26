# power_nap = fn ->
#     time = :rand.uniform(10_000)
#     :timer.sleep(time)
#     time
#   end

# parent = self()

# spawn a new process
# send back a message back to the parent of the form {:sleep, time}
# spawn(fn -> send(parent, power_nap.()) end)

# receive the message
# receive do 
#     {:result, time} -> IO.puts "Slept #{time} ms"
# end

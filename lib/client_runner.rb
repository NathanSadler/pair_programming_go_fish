require_relative 'go_fish_client'

user_client = GoFishClient.new

# Not all text output will require users to input something, so address that
# when you get the chance
while true
  sleep(1)
  recieved_message = user_client.capture_output
  if(!recieved_message.nil? && recieved_message != "")
    puts(recieved_message)
    user_client.provide_input(gets)
  end
end

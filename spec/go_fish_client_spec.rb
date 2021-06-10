require_relative '../lib/go_fish_client'
require_relative '../lib/go_fish_server'
require 'socket'

describe 'GoFishClient' do
  let!(:test_server) {TCPServer.new(3337)}

  after(:each) do
    test_server.close
  end

  context '#capture_output' do
    it('#gets a message the server sent to it') do
      test_client = GoFishClient.new(3337)
      server_side_socket = test_server.accept_nonblock
      server_side_socket.puts("This is a test")
      expect(test_client.capture_output).to(eq("This is a test"))
      test_client.close
    rescue IO::WaitReadable
      expect(false).to be true
    end
  end

  context '#provide_input' do
    it("sends input to the server") do
      test_client = GoFishClient.new(3337)
      server_side_client = test_server.accept_nonblock
      test_client.provide_input("Hello World")
      expect(server_side_client.gets.chomp).to(eq("Hello World"))
      test_client.close
    end
  end
end

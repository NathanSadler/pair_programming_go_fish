require_relative '../lib/go_fish_server'
require_relative '../lib/player'
require 'socket'

describe 'GoFishServer' do
  let(:server) {GoFishServer.new}

  after(:each) do
    server.stop
  end

  context('#accept_client') do
    it("creates a Player object from a client") do
      server.accept_client
      expect(server.clients.empty?).to(eq(true))
      test_socket = TCPSocket.new('localhost', 3336)
      expect(server.clients.length).to(eq(0))
    end
  end

end

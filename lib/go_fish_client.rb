require 'socket'
class GoFishClient
  attr_accessor :socket
  def initialize(port=3336, server='localhost')
    @socket = TCPSocket.new(server, port)
  end

  def close
    socket.close
  end

  def capture_output
    sleep(0.1)
    socket.read_nonblock(1000).chomp!
  rescue IO::WaitReadable, EOFError
    ""
    #retry
  end

  def provide_input(input)
    socket.puts(input)
  end
end

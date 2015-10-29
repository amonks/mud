#The server class creates a single instance of a mud server.
class MudServer
  attr_accessor :connection_pool, :tcp_socket,
                :connection_acceptor, :port, :ip, :environment

  def initialize(ip = "0.0.0.0", port = 4000, environment = 'development')
    bootstrap_settings(ip, port, environment)
  end

  def bootstrap_settings(ip, port, environment)
    @port            = port
    @ip              = ip
    @environment     = environment
    @connection_pool = [] # This is where we keep reference to all game
                          # connections
  end

  def start
    @tcp_socket = TCPServer.new @ip, @port
    @connection_acceptor = Thread.new do
      while connection = @tcp_socket.accept
        @connection_pool << MudServer::Session.new(connection)
      end
    end
    return true
  end

  def broadcast message, sender
    puts 'broadcasting'
    @connection_pool.each do |session|
      out = format_message message, sender, session
      session.connection.puts out
    end
  end

  def herecast message, sender, controller = sender.controller
    puts "herecasting to #{controller}"
    players_in(controller).each do |session|
      out = format_message message, sender, session
      session.connection.puts out
    end
  end

  def players_in controller
    @connection_pool.select {|session|
      session.controller.class == controller.class
    }
  end

  def format_message message, sender, session, verb = 'said'
    if sender.class == String
      from = sender
    else
      if sender == session
        from = 'you'
      else
        from = sender.instance_variable_get("@name")
      end
    end
    message.gsub('%from', from)
  end



  # You probably won't need this one in production, but it's a must for testing.
  def stop
    broadcast "The game is now shutting down", "the server"
    @tcp_socket.close
    @connection_acceptor.kill
    @connection_acceptor = nil
    return true
  end

end

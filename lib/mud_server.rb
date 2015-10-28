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
    @tcp_socket = TCPServer.new @ip , @port
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
      out = say message, sender, session, 'shouted'
      session.connection.puts out
    end
  end

  def herecast message, sender, controller
    puts "herecasting to #{controller}"
    @connection_pool.each do |session|
      if session.controller.class == controller.class
        out = say message, sender, session
        session.connection.puts out
      end
    end
  end

  def say message, sender, session, verb = 'said'
    if sender.class == String
      from = sender
    else
      if sender == session
        from = 'You'
      else
        from = sender.instance_variable_get("@name")
      end
    end
    "#{from} just #{verb}: \"#{message}\"."
  end



  # You probably won't need this one in production, but it's a must for testing.
  def stop
    @tcp_socket.close
    @connection_acceptor.kill
    @connection_acceptor = nil
    return true
  end

end

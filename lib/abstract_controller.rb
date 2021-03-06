# Transfers input/output from the Telnet world into the Ruby world while
# abstracting away all the rough spots.
# All controllers should inherit from here
class MudServer::AbstractController
  include MudServer::Helpable

  attr_accessor :session, :params

  # Instantiates a new controller instance. It is highly recomended that derived
  # controller classes either not modify this method, call super, or proxy via a
  # helper method (such as create() or buil(), etc).
  #
  # * +session+ - (Session) The connection session that the controller will
  # communicate with.
  def initialize(session)
    @session = session
    @session.controller = self
    send_text "\n\n"
    on_start
    true
  end

  # User definable callback called after instantiation.
  def on_start
  end

  # Sends a string to remote client over the TCP socket connection.
  def send_text(command)
    @session.connection.puts(command)
  end

  def send_list list
    list.each do |item|
      send_text " - #{item}"
    end
  end

  # Void paramaterless controller action that closes TCP socket to client.
  # You must whitelist this command in allowed_methods() in order for it to be
  # usable by players.
  def quit_
    "Leave the game"
  end
  def quit
    $server.herecast "%from just quit the game", @session, @session.controller
    session.connection.close
    server.disconnect @session
  end

  # return server time
  def time_
    "Print the current time"
  end
  def time
    send_text "The time is now #{Time.now}"
  end

  # Parses arbitrary user input into a format usable by the interpreter. Strips
  # all input after initial command and stores it in `params`.
  #
  # * +command+ - (String) A string of space seperated commands and arguments
  #
  #    parse_command('login user_x password123')
  #    # => True
  #    params() # Note: side effects
  #    # => 'user_x password123'
  def get_text(command)
    command = command.split(' ')
    head    = command.shift
    @params = command.join(' ')
    interpret_command head.to_s.downcase
  end

  # Interprets a controller command (first argument of user input)
  #
  # * +head+ - (String) The command to execute. Will only execute the command if
  # it is within the 'allowed_methods' dynamic array.
  #
  #    interpret_command('add') # Assumes the current controller has
  #                             # an add() method defined and within
  #    # => 10                  # the allowed_methods Array.
  def interpret_command(head)
    if allowed_methods.include? head
      self.send(head)
    else
      send_error
    end
  rescue => error
    send_text 'Something just broke. Please tell the admins about this.'
    send_text error.message
    puts error.message
  end

  # A whimsical way of telling the user they input an unknown /
  # unauthorized command. Override this if you want a '404 page' on
  # your controller
  def send_error
    send_text funny_responses.sample
  end

  # Parameterless method used for generating quirky messages when the
  # user attempts to use a non-existant / forbidden controller action.
  # Returns String.
  def funny_responses
    [
      'Huh?',
      "What's that you say?",
      'come again?',
      "Sorry, I don't know that command."
    ]
  end

  # Dynamically generated list of user accesible controller methods. By default
  # (and when used in conjugation with +super+ in derived classes), will return
  # ['quit'] as its only accessible method. Returns Array of Strings.
  def allowed_methods
    ['quit', 'time', 'help', 'commands']
  end

  # Transfers control from on controller to another. Eg: Move from login
  # controler to main game.
  def transfer_to(controller_name)
    @session.controller = controller_name.new(@session)
  end
end

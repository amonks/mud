class MudServer
  module Helpable
    # return server time
    def commands_
      "Print a list of commands"
    end
    def commands
      send_text "Here's a list of available commands:"
      send_list allowed_methods.map {|c| "#{c.upcase}: #{send(c + '_')}"}
        .sort_by {|c| c}
    end
    alias_method :help_, :commands_
    alias_method :help, :commands

    def method_missing m, *args, &block
      return '???' if m.to_s[-1, 1] == '_'
      raise NoMethodError
    end
  end
end

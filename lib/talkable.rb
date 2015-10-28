class MudServer
  module Talkable
    # set player name
    def name_
      "Set your name"
    end
    def name
      @session.instance_variable_set("@name", params)
      send_text "Your name is #{params}."
    end

    def shout_
      "Shout something to everyone"
    end
    def shout
      $server.broadcast "%from just shouted \"#{params}\"", @session
    end

    def say_
      "Say something to the people here"
    end
    def say
      $server.herecast "%from just said \"#{params}\"", @session, @session.controller
    end

    def allowed_methods
      super + ['name', 'say', 'shout']
    end
  end
end

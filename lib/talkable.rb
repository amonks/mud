class MudServer
  module Talkable
    # set player name
    def name
      @session.instance_variable_set("@name", params)
      send_text "Your name is #{params}."
    end

    def shout
      $server.broadcast params, @session
    end

    def say
      $server.herecast params, @session, @session.controller
    end

    def allowed_methods
      super + ['name', 'say', 'shout']
    end
  end
end

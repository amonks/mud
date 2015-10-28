class MudServer::Location < MudServer::AbstractController
  include MudServer::Talkable

  def on_start
    arrive
    look
  end

  def look_
    "Look around"
  end
  def look
    send_text "You are #{location_prepositional_phrase}."

    send_text "Possible exits include:"
    send_list destinations

    if players_here.length == 1
      send_text "#{players_here.first} is here."
    elsif players_here.length > 1
      send_text "The following people are here:"
      send_list players_here
    end
  end

  def who_
    "Get a list of who is here"
  end
  def who
    send_list players_here
  end

  def who_
    "Get a list of who is here"
  end
  def who
    send_list players_here
  end

  def allowed_methods
    super + destinations + ['who', 'look']
  end

  def arrive
    $server.herecast "%from just arrived here", @session, @session.controller
  end

  def depart_for destination
    $server.herecast "%from is leaving for a #{destination}", @session, @session.controller
  end

  def transfer_to destination
    depart_for destination.name
    super
  end

  def players_here
    $server.players_in(self)
      .select {|session| session != @session}
      .map { |session| session.name }
  end

  def destinations
    []
  end

  def method_missing m, *args, &block
    loc = m.to_s.chomp '_'
    return "Go to #{loc}" if destinations.include? loc
    super
  end
end

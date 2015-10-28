module MudServer::Clock
  def initialize
    Thread.new do
      while true do
        tick
        sleep 1
      end
    end
  end

  def tick
  end
end

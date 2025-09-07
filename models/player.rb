class Player
  attr_accessor :name, :client, :current_room
  
  def initialize(client, name, current_room)
    @client = client
    @name = name
    @current_room = current_room
  end
end
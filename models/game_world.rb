require 'json'
require 'thread'
require_relative 'room'
require_relative 'player'

class GameWorld
  attr_reader :rooms, :players, :players_mutex

  def initialize
    @rooms = {}
    @players = {}
    @players_mutex = Mutex.new
    load_rooms_from_file
  end

  # The load method now knows to look in the 'data' folder
  def load_rooms_from_file
    puts "Loading rooms from file..."
    
    # Read the JSON file from the data folder
    file_path = File.join(__dir__, '../data/rooms.json')
    room_data = JSON.parse(File.read(file_path))

    # Create Room objects and store them in a hash using their integer ID as the key
    room_data.each do |data|
      room = Room.new(data)
      @rooms[room.id] = room
    end
    
    puts "Loaded #{@rooms.size} rooms."
  end

  # Finds a room by its ID (e.g., 1, 2, 3)
  def find_room(room_id)
    @rooms[room_id]
  end
  
  # Adds a player to the shared list
  def add_player(player)
    @players_mutex.synchronize do
      @players[player.name] = player
    end
  end
  
  # Removes a player from the shared list
  def remove_player(player)
    @players_mutex.synchronize do
      @players.delete(player.name)
    end
  end
end
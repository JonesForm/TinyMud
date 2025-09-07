require 'socket'
require_relative 'models/game_world'
require_relative 'models/player'

def send_formatted_message(client, message)
  width = 70
  words = message.split
  lines = [""]
  
  words.each do |word|
    if (lines.last + " " + word).length <= width
      lines[-1] << " " unless lines.last.empty?
      lines[-1] << word
    else
      lines << word
    end
  end

  lines.each do |line|
    client.print "#{line}\r\n"
  end
end

def send_message(client, message)
    client.print "#{message}\r\n" 
end

def display_room_info(client, room)
  send_message(client, "=======================================================")
  send_formatted_message(client, room.full_description)
  send_formatted_message(client, room.exits_description)
  send_message(client, "=======================================================")
end

# choose a port for the server to run from
PORT = 2000

# create a new TCP server and listen on the chosen port
server = TCPServer.new(PORT)
puts "MUD server is now listening on port #{PORT}."

# create the world
game_world =GameWorld.new

# main server loop for accepting new connection
while true
  # wait for the player to connect
  client_socket = server.accept

  # spawn a thread for the new player that has connected
  Thread.new(client_socket) do |client|
    begin
    client_address = client.peeraddr[2]

    # ---- New player give name ----
    player_name = ''
    loop do
      send_message(client, "Please enter a name: ")
      player_name = client.gets&.chomp
      if player_name.to_s.empty?
        send_message(client, "your name cannot be empty")
      else
        break
      end
    end
    # ---- End of naming ----

    # Create and add the player to the world
    starting_room = game_world.find_room(1)
    player = Player.new(client, player_name, starting_room)
    game_world.add_player(player)

    puts "A new player has connected '#{player_name}' from #{client_address}"

    # give the player their starting room
    current_room = game_world.find_room(1)

    # send a welcome message to the player
    send_message(client, "Welcome #{player_name} to the Ruby MUD that is being created.")
    display_room_info(client, current_room)
    # wait for a command from the player
    loop do
      command = client.gets&.chomp

      # see what the command is to do
      if command.nil? || command.downcase == "quit"
        break
      elsif command.downcase.start_with?("say ")
        message = command.split(' ', 2)[1]
        game_world.players.values.each do |other_player|
          if other_player.current_room == player.current_room && other_player != player
            send_message(other_player.client, "#{player.name} says: #{message}")
          end
        end
        send_message(client, "You say: #{message}")
      elsif command.downcase.start_with?("shout ")
        message = command.split(' ',2)[1]
        game_world.players.values.each do |other_player|
          send_message(other_player.client, "[GLOBAL] #{player.name}: #{message}")
        end
      elsif command.downcase == "look"
        display_room_info(client, current_room)
      elsif current_room.exits.key?(command.downcase)
        new_room_id = current_room.exits[command.downcase]
        current_room = game_world.find_room(new_room_id)
        send_message(client, "You move #{command.downcase}.")
        display_room_info(client, current_room)
      end
    end

    rescue Errno::EPIPE, IOError => e
      #this will run if a broken pipe happens
      puts "A network error with #{player_name} from #{client_address}"
    ensure
      # This will run regardless
      # close the connect with the player
      client_socket.close
      puts "The player has disconnected"
    end
  end
end
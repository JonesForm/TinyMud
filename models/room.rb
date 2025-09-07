class Room
  attr_reader :id, :name, :description, :exits

  def initialize(room_data)
    @id = room_data["id"]
    @name = room_data["name"]
    @description = room_data["description"]
    @exits = room_data["exits"] || {} # Handle rooms with no exits
  end

  # Returns the room name and description as a single, unformatted string
  def full_description
    "#{@name}\n\n#{@description}\n"
  end

  # Returns the exit information as a separate string
  def exits_description
    exit_list = @exits.keys.join(", ")
    exit_info = exit_list.empty? ? "" : "Exits are to the #{exit_list}."
    exit_info
  end
end
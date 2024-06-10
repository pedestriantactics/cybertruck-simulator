extends Node

var kvps = {}

var saved_kvps = {}

func _ready():
	load_save_file()

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(saved_kvps)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

func clear():
	saved_kvps = {}

func has_save_file():
	return FileAccess.file_exists("user://savegame.save")

func clear_save():
	clear()
	save()
	print("Save file cleared.")

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_save_file():

	clear()

	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Now we set the remaining variables.
		for i in node_data.keys():
			saved_kvps[i] = node_data[i]
extends Node

# this tracks sessions in the game

var sessions = []
var current_session = []
var current_scene_name = ""
var current_scene_seconds = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save_file()
	sessions.append(current_session)

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save():
	cleanup()
	var save_game = FileAccess.open("user://playtime.save", FileAccess.WRITE)
	var json_string = JSON.stringify(sessions)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

func clear():
	sessions = []

func has_save_file():
	return FileAccess.file_exists("user://playtime.save")

func clear_save():
	clear()
	save()
	print("Save file cleared.")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		current_session.append(current_scene_name + ": " + str(round(current_scene_seconds)))
		save()

func _process(delta):
	# check if the current scene name is different than the last one
	var scene = get_tree().get_current_scene()
	var new_scene_name = ""
	if scene != null:
		new_scene_name = get_tree().get_current_scene().get_name()
	if current_scene_name != new_scene_name:
		# save the time spent in the current scene
		# it will be formatted as scenename: time (rounded to seconds)
		current_session.append(current_scene_name + ": " + str(round(current_scene_seconds)))
		current_scene_name = new_scene_name
		current_scene_seconds = 0.0
		print("Scene changed to: ", new_scene_name)
		print("Current session saved: ", current_session)
		save()
	# add delta to the current scene name in the session
	current_scene_seconds += delta

func cleanup():
	# remove blank entries from the session by checking if the entry starts with:
	# ":", which is the separator we used to save the scene name and time
	for i in range(current_session.size()):
		if current_session[i].begins_with(":"):
			current_session.remove_at(i)
			i -= 1
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_save_file():

	clear()

	if not FileAccess.file_exists("user://playtime.save"):
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
	var save_game = FileAccess.open("user://playtime.save", FileAccess.READ)
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
		if node_data != null && node_data != []:
			sessions = node_data

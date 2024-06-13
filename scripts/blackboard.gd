extends Node

var kvps = {}

var saved_kvps = {}

# for playtime tracking
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
	cleanup_current_session()
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var savable_data = {}
	savable_data["saved_kvps"] = saved_kvps
	savable_data["sessions"] = sessions
	var json_string = JSON.stringify(savable_data)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

func clear():
	saved_kvps = {}
	sessions = []

func cleanup_current_session():
	# remove blank entries from the session by checking if the entry starts with:
	# ":", which is the separator we used to save the scene name and time
	for i in range(current_session.size()):
		if current_session[i].begins_with(":"):
			current_session.remove_at(i)
			i -= 1

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

		if node_data.has("saved_kvps"):
			# Now we set the remaining variables.
			var in_saved_kvps = node_data["saved_kvps"]
			for i in in_saved_kvps.keys():
				saved_kvps[i] = in_saved_kvps[i]
		if node_data.has("sessions"):
			var in_sessions = node_data["sessions"]
			sessions = in_sessions

func _add_current_scene_time_to_session():
	current_session.append(current_scene_name + ": " + str(round(current_scene_seconds)))
	# check and add total play time
	if current_scene_name == "Play":
		# get and add to total playtime
		var play_time_counter_name = "total_play_time_in_game"
		var current_play_time = 0
		if saved_kvps.has(play_time_counter_name):
			current_play_time = saved_kvps[play_time_counter_name]
		current_play_time += current_scene_seconds
		saved_kvps[play_time_counter_name] = current_play_time

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_add_current_scene_time_to_session()
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
		_add_current_scene_time_to_session()
		current_scene_name = new_scene_name
		current_scene_seconds = 0.0
		save()
	# add delta to the current scene name in the session
	current_scene_seconds += delta

extends Control

# this is toggled by hitting the "dev_console" key defined in the project settings

# when the key is pressed the game will pause and the child line edit will be shown and the focus will be set to it
# when the key is pressed again the line edit will be hidden and the game will resume

# when the line edit is shown, pressing the return key will hide the console and execute the command if there is one
# the command will printed and a signal will fire with the command as a string argument

# the line edit to show and hide
@onready var line_edit = get_child(1)
@onready var console_label = get_child(2)

# create a dictionary called glossary
# this will have key value pairs. The key will be the command and the value will be the description
var help_text: Dictionary = {}

signal command(text_command)

# Called when the node enters the scene tree for the first time.
func _ready():
	command.connect(on_command)
	visible = false

	# add the help text
	help_text["r"] = "reload the scene"
	help_text["d"] = "dev mode for truck"
	help_text["cs"] = "change the scene"
	help_text["bb"] = "add to blackboard if there's a command after, otherwise check the blackboard"

func on_command(text_command):
	# add a carriage return and the command to the console
	debug_print("")
	debug_print("")
	debug_print("command entered: " + text_command)
	debug_print("")

	# exact dev console commands go here
	match text_command:
		"help":
			debug_print("dev console commands:")
			for key in help_text:
				# get the character count of the key
				var key_length = key.length()
				var space = 12
				var space_count = space - key_length
				var space_string = ""
				for i in range(space_count):
					space_string += " "
				debug_print(key + space_string + help_text[key])
			return
		"r":
			# reload the scene
			get_tree().reload_current_scene()
			return
		"d":
			# dev mode for truck 
			command.emit("burst")
			command.emit("steering .8")
			command.emit("rpm 300")
			return
		"bb":
			var blackboard = get_node("/root/Blackboard")
			debug_print("blackboard contents:")
			for key in blackboard.kvps:
				debug_print(key + " " + str(blackboard.kvps[key])) 
			return
		"sbb":
			var blackboard = get_node("/root/Blackboard")
			debug_print("saved blackboard contents:")
			for key in blackboard.saved_kvps:
				debug_print(key + " " + str(blackboard.saved_kvps[key])) 
			return
	
	# contains dev console commands go here
	var keyword = ""

	# change the scene
	keyword = "cs"
	if text_command.begins_with(keyword):
		var keyword_result = text_command.replace(keyword, "").replace(" ", "")
		var scene_changer = get_node("/root/SceneChanger")
		scene_changer.change_scene(keyword_result)
		return

	# add to blackboard
	keyword = "bb"
	if text_command.begins_with(keyword):
		if !text_command.contains(","):
			debug_print("not enough arguments for blackboard")
			debug_print("use a comma to separate arguments")
			return
		var keyword_result = text_command.replace(keyword, "").replace(" ", "").split(",")
		var blackboard = get_node("/root/Blackboard")
		var number_result = float(keyword_result[1])
		blackboard.kvps[keyword_result[0]] = number_result
		debug_print("added to blackboard: " + keyword_result[0] + " " + keyword_result[1])
		return
	
	# add to saved blackboard
	keyword = "sbb"
	if text_command.begins_with(keyword):
		if !text_command.contains(","):
			debug_print("not enough arguments for blackboard")
			debug_print("use a comma to separate arguments")
			return
		var keyword_result = text_command.replace(keyword, "").replace(" ", "").split(",")
		var blackboard = get_node("/root/Blackboard")
		blackboard.saved_kvps[keyword_result[0]] = keyword_result[1]
		debug_print("added to saved blackboard: " + keyword_result[0] + " " + keyword_result[1])
		blackboard.save()
		return

func debug_print(in_text):
	console_label.text += "\n" + in_text

# when the key is pressed
func _input(event):
	if event.is_action_released("dev_console") and Input.is_action_pressed("dev_console_1"):
		if visible:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			line_edit.grab_focus()
			get_tree().paused = true
			# clear it, otherwise the = ends up in there
			line_edit.text = ""

	# when the line edit is shown and the return key is pressed
	if event.is_action_released("ui_text_completion_accept") and visible:

		# get the command
		var text_command = line_edit.text

		# clear the line edit
		line_edit.text = ""

		# emit the signal
		command.emit(text_command)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

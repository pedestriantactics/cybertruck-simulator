extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	DevConsole.command.connect(handle_command)
	DevConsole.help_text["ui"] = "Toggle the visibility of the UI."

func handle_command(text_command):
	match text_command:
		"ui":
			visible = not visible
			DevConsole.debug_print("UI visibility: " + str(visible))

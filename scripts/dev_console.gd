extends Control

# this is toggled by hitting the "dev_console" key defined in the project settings

# when the key is pressed the game will pause and the child line edit will be shown and the focus will be set to it
# when the key is pressed again the line edit will be hidden and the game will resume

# when the line edit is shown, pressing the return key will hide the console and execute the command if there is one
# the command will printed and a signal will fire with the command as a string argument

signal command(command)

# the line edit to show and hide
@onready var line_edit = get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# when the key is pressed
func _input(event):
	if event.is_action_pressed("dev_console"):
		if line_edit.visible:
			line_edit.visible = false
			get_tree().paused = false
		else:
			line_edit.visible = true
			line_edit.grab_focus()
			get_tree().paused = true

	# when the line edit is shown and the return key is pressed
	if event.is_action_pressed("ui_accept") and line_edit.visible:
		# hide the line edit
		line_edit.visible = false
		get_tree().paused = false

		# get the command
		var command = line_edit.text

		# clear the line edit
		line_edit.text = ""

		# print the command
		print(command)

		# emit the signal
		emit_signal("command", command)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

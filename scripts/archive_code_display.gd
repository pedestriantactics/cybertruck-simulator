# this displays the current archive code (version number) using the label

extends Label

func _ready():
	# get globals and set the label text
	var globals = get_node("/root/Globals")
	text = globals.archive_code
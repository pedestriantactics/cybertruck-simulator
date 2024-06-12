extends Area3D

@onready var audio_stream_player = $AudioStreamPlayer
var next_goal = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# get sibling nodes by getting the parent and determining which index this node is from the children
	var parent = get_parent()
	var index = get_index()
	next_goal = parent.get_child(index + 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !visible:
		return
	# check if the player is inside the goal by checking if intersecting bodies are vehiclebody3d
	if !has_overlapping_bodies():
		return
	
	for body in get_overlapping_bodies():
		if body is VehicleBody3D:
			# play the sound
			audio_stream_player.play()
			# complete this goal by deactivating it and making it invisible
			visible = false
			# activate the next goal
			if next_goal != null:
				next_goal.visible = true


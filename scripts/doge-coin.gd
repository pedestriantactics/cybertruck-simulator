extends Node3D

@onready var area = $Area3D
@onready var audio_stream_player = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# check if the area3D is colliding
	var bodies = area.get_overlapping_bodies()
	if bodies != null:
		for body in bodies:
			if body is VehicleBody3D:
				visible = 0
				set_physics_process(false)
				audio_stream_player.play()
				var blackboard = get_node("/root/Blackboard")
				if blackboard != null:
					blackboard.kvps["dogecoin_collected"] = 1
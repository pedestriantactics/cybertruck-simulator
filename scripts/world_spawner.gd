extends Node3D

@export var spawn_path: NodePath


# Called when the node enters the scene tree for the first time.
func _ready():
	# get the first child of the node and get the children of it
	var children = get_child(0).get_children()
	for child in children:
		# log the name
		print(child.name)
		# if the child name includes "prop-" destroy it
		if child.name.find("prop_") != -1:
			child.queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

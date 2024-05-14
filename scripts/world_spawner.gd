extends Node3D

@export var spawn_path: NodePath


# Called when the node enters the scene tree for the first time.
func _ready():
	# get the first child of the node and get the children of it
	var children = get_child(0).get_children()
	for child in children:
		# if the child name includes "prop_" replace the underscore with a dash, then load the prefab from the props folder with the same name and spawn it
		if child.name.contains("prop-"):
			# blender objects contain an _ followed by numbers after the name, split by that name and remove everything after and also the period
			var final_name = child.name.split("_")[0]
			var prop = load("res://props/" + final_name + ".tscn")
			if prop == null:
				print("Could not load prop: " + final_name)
				continue
			var instance = prop.instantiate()
			instance.position = child.position;
			instance.rotation = child.rotation;
			add_child(instance)
			child.queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

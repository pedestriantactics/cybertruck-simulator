extends Node3D

@export var spawn_path: NodePath


# Called when the node enters the scene tree for the first time.
func _ready():
	# get the first child of the node and get the children of it
	var children = get_child(0).get_children()
	# spawn points
	# var spawn_points = []
	var doge_coins = []
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
			instance.name = final_name
			child.queue_free()
		
		if child.name.contains("spawn-point"):
	# 		print("spawn found")
	# 		# create a new node3d at the point
	# 		var instance = Node3D.new()
	# 		instance.position = child.position;
	# 		instance.rotation = child.rotation;
	# 		add_child(instance)
	# 		instance.name = "spawn-point"
	# 		print(instance)
	# 		spawn_points.append(instance)
			child.queue_free()

		if child.name.contains("doge-coin"):
			var prop = load("res://prefabs/doge-coin.tscn")
			if prop == null:
				print("Could not load doge coin")
				continue
			var instance = prop.instantiate()
			instance.position = child.position;
			instance.rotation = child.rotation;
			add_child(instance)
			doge_coins.append(instance)
			child.queue_free()

	# reduce doge coins to 1
	if doge_coins.size() == 0:
		print("no doge coins")
		return
	var selected_coin_index = randi() % doge_coins.size()
	doge_coins.remove_at(selected_coin_index)
	for coin in doge_coins:
		coin.queue_free()
	# var spawn_point = spawn_points[randi() % spawn_points.size()]
	# # get the car and move it to that point
	# # var car = get_node("Cybertruck")
	# var car = load("res://prefabs/cybertruck.tscn")
	# var instance = car.instantiate()
	# instance.position = spawn_point.position
	# instance.rotation = spawn_point.rotation
	# # destroy the spawn points
	# for point in spawn_points:
	# 	point.queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

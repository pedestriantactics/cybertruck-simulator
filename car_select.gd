extends Control


var town = null


func _process(_delta):
	if Input.is_action_just_pressed("back"):
		_on_Back_pressed()


func _load_scene():
	# load the car
	var tt = load("res://car_base.tscn").instantiate()
	tt.set_name("car")
	town = load("res://town_scene.tscn").instantiate()
	town.get_node("InstancePos").add_child(tt)
	town.get_node("Back").connect("pressed", Callable(self, "_on_Back_pressed"))
	get_parent().add_child(town)
	hide()


func _on_Back_pressed():
	if is_instance_valid(town):
		# Currently in the town, go back to main menu.
		town.queue_free()
		show()
	else:
		# In main menu, exit the game.
		get_tree().quit()


func _on_MiniVan_pressed():
	_load_scene()

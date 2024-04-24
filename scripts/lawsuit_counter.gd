extends Label

# this stores a reference to the car in the scene and tracks the targets that it hits
# when the car hits a RigidBody2D it stores the name of the object in a list
# if the car hits the same object again it does not add it to the list

@export var car_path: NodePath
@onready var car = get_node(car_path)
@onready var blackboard = get_node("/root/Blackboard")

var targets_hit = []
var trees_hit = 0

func _ready():
	# add it to the blackboard
	blackboard.kvps["lawsuits"] = 0
	car.object_collision_occurred.connect(_on_collision_occurred)
	pass

func _on_collision_occurred(impact, collision_info):
	var collision_name = collision_info.get_collider().get_name()
	if (targets_hit.find(collision_name) == - 1):
		targets_hit.append(collision_name)
		print("hit " + collision_name)
		text = "Lawsuits " + str(targets_hit.size())
		# add it to the blackboard
		blackboard.kvps["lawsuits"] = targets_hit.size()
		# trees!
		if (collision_name.find("Tree") != -1):
			trees_hit += 1
			blackboard.kvps["trees_hit"] = trees_hit

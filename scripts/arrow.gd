extends Node3D

# this will look for the goal's node and point at it
# the position is stored in the goal manager
@export var goal_manager_node_path: NodePath
@onready var goal_manager_node = get_node(goal_manager_node_path)

func _process(delta):
	if goal_manager_node.current_goal_global_position.y > 10:
		visible = false
		return
	# rotate the arrow along the y axis to point at the goal
	var target = goal_manager_node.current_goal_global_position
	var direction = target - global_transform.origin
	# turn that into a rotation which will be applied to the rotation property on this object
	var new_rotation = Basis()
	new_rotation = new_rotation.rotated(Vector3(0, 1, 0), atan2(direction.x, direction.z))
	# rotate 180 degrees to point in the right direction
	new_rotation = new_rotation.rotated(Vector3(0, 1, 0), PI)
	# grab the current scale and add that to the basis
	new_rotation = new_rotation.scaled(global_transform.basis.get_scale())
	global_transform.basis = new_rotation